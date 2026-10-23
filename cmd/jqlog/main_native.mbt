///|
priv enum InputSource {
  Stdin
  File(String)
  Inline(String)
}

///|
priv struct CliOptions {
  query : String
  input : InputSource
}

///|
priv enum CliParseResult {
  Error(String)
  Run(CliOptions)
}

///|
fn jqlog_command() -> @argparse.Command {
  Command(
    "jqlog",
    about="Run jq filters over JSON Lines input, skipping non-JSON lines.",
    options=[
      OptionArg("file", short='f', about="Read input text from a file.", conflicts_with=[
        "input",
      ]),
    ],
    positionals=[
      PositionArg(
        "query",
        about="The jq filter to evaluate.",
        num_args=@argparse.ValueRange::single(),
      ),
      PositionArg(
        "input",
        about="Input text; omit or use - to read stdin.",
        num_args=ValueRange(lower=0, upper=1),
        allow_hyphen_values=true,
        conflicts_with=["file"],
      ),
    ],
    disable_help_subcommand=true,
  )
}

///|
fn parse_cli(args : ArrayView[String]) -> CliParseResult {
  let matches = jqlog_command().parse(argv=args, env=Map([])) catch {
    err => return Error(err.to_string())
  }
  let query = matches.values.get("query").unwrap()[0]
  let input = match matches.values {
    { "file": [path], .. } => File(path)
    { "input": ["-"], .. } => Stdin
    { "input": [text], .. } => Inline(text)
    _ => Stdin
  }
  Run({ query, input, })
}

///|
async fn read_input(source : InputSource) -> String {
  match source {
    Stdin => @stdio.stdin.read_all().text()
    File(path) => @fs.read_file_to_string(path)
    Inline(text) => text
  }
}

///|
async fn write_results(results : Iter[Result[Json, @moonjq.EvalError]]) -> Unit {
  for result in results {
    let value = match result {
      Ok(v) => v
      Err(err) => raise err
    }
    @stdio.stdout.write(value.stringify())
    @stdio.stdout.write("\n")
  }
}

///|
async fn main {
  let args = @env.args()[1:]
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
      let query = @moonjq.parse(options.query) catch {
        err => {
          @stdio.stderr.write("Error: \{err}\n")
          @sys.exit(3)
          return
        }
      }
      try {
        let input = read_input(options.input)
        write_results(query.eval_logs(input))
      } catch {
        err => {
          @stdio.stderr.write("Error: \{err}\n")
          @sys.exit(5)
          return
        }
      }
    }
  }
}
