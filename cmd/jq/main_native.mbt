///|
priv enum InputSource {
  Stdin
  File(String)
}

///|
priv enum QuerySource {
  Inline(String)
  File(String)
}

///|
priv struct CliOptions {
  query : QuerySource
  inputs : Array[InputSource]
  logs : Bool
  raw_output : Bool
  compact_output : Bool
  null_input : Bool
}

///|
priv enum CliParseResult {
  Error(String)
  Run(CliOptions)
}

///|
fn jq_command() -> @argparse.Command {
  Command(
    "moonjq",
    about="Run jq filters over JSON input.",
    flags=[
      FlagArg(
        "compact-output",
        short='c',
        about="Print compact JSON instead of pretty JSON.",
      ),
      FlagArg(
        "logs",
        short='l',
        about="Treat input as newline-delimited JSON logs.",
        conflicts_with=["null-input"],
      ),
      FlagArg(
        "null-input",
        short='n',
        about="Run the filter once with null input.",
        conflicts_with=["logs"],
      ),
      FlagArg(
        "raw-output",
        short='r',
        about="Print strings without JSON quotes.",
      ),
    ],
    options=[
      OptionArg(
        "from-file",
        short='f',
        about="Read the filter from FILE.",
        action=Append,
      ),
    ],
    positionals=[
      PositionArg(
        "args",
        about="<filter> [file...]",
        num_args=ValueRange(lower=0),
      ),
    ],
    disable_help_subcommand=true,
  )
}

///|
fn parse_cli(args : ArrayView[String]) -> CliParseResult {
  let command = jq_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => return Error(err.to_string())
  }
  let positionals = matches.values.get("args").unwrap_or([])
  let filter_files = matches.values.get("from-file").unwrap_or([])
  let query = match filter_files.length() {
    0 => {
      if positionals.is_empty() {
        return Error("error: missing filter\n\n" + command.render_help())
      }
      QuerySource::Inline(positionals[0])
    }
    1 => File(filter_files[0])
    _ =>
      return Error(
        "error: multiple filters provided\n\n" + command.render_help(),
      )
  }
  let input_start = if filter_files.is_empty() { 1 } else { 0 }
  let inputs : Array[InputSource] = []
  for index in input_start..<positionals.length() {
    let path = positionals[index]
    if path == "-" {
      inputs.push(Stdin)
    } else {
      inputs.push(File(path))
    }
  }
  if inputs.is_empty() && !matches.flags.get_or_default("null-input", false) {
    inputs.push(Stdin)
  }
  Run({
    query,
    inputs,
    logs: matches.flags.get_or_default("logs", false),
    raw_output: matches.flags.get_or_default("raw-output", false),
    compact_output: matches.flags.get_or_default("compact-output", false),
    null_input: matches.flags.get_or_default("null-input", false),
  })
}

///|
fn read_query(source : QuerySource) -> String raise {
  match source {
    Inline(text) => text
    File(path) => @fs.read_file_to_string(path)
  }
}

///|
async fn read_input(source : InputSource) -> String {
  match source {
    Stdin => @stdio.stdin.read_all().text()
    File(path) => @fs.read_file_to_string(path)
  }
}

///|
fn run_query(
  query : @moonjq.Query,
  input : String,
  logs : Bool,
) -> Iter[Json] raise {
  if logs {
    query.eval_logs(input)
  } else {
    let json = @json.parse(input)
    query.eval(json)
  }
}

///|
fn render_result(
  value : Json,
  raw_output : Bool,
  compact_output : Bool,
) -> String {
  if raw_output {
    match value {
      String(text) => text
      _ => value.stringify(indent=if compact_output { 0 } else { 2 })
    }
  } else {
    value.stringify(indent=if compact_output { 0 } else { 2 })
  }
}

///|
async fn write_results(
  results : Iter[Json],
  raw_output : Bool,
  compact_output : Bool,
) -> Unit {
  for value in results {
    @stdio.stdout.write(render_result(value, raw_output, compact_output))
    @stdio.stdout.write("\n")
  }
}

///|
async fn main {
  let args = @sys.get_cli_args()[1:]
  match parse_cli(args) {
    Error(msg) => {
      @stdio.stderr.write(msg)
      if !msg.has_suffix("\n") {
        @stdio.stderr.write("\n")
      }
      @sys.exit(2)
      return
    }
    Run(options) => {
      let query_text = read_query(options.query) catch {
        err => {
          @stdio.stderr.write("moonjq: \{err}\n")
          @sys.exit(2)
          return
        }
      }
      let query = @moonjq.parse(query_text) catch {
        err => {
          @stdio.stderr.write("moonjq: \{err}\n")
          @sys.exit(3)
          return
        }
      }
      try {
        if options.null_input {
          write_results(
            query.eval(null),
            options.raw_output,
            options.compact_output,
          )
        } else {
          for input_source in options.inputs {
            let input = read_input(input_source)
            write_results(
              run_query(query, input, options.logs),
              options.raw_output,
              options.compact_output,
            )
          }
        }
      } catch {
        err => {
          @stdio.stderr.write("moonjq: \{err}\n")
          @sys.exit(5)
          return
        }
      }
    }
  }
}
