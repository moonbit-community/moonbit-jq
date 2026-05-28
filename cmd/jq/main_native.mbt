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
  Help
  Error(String)
  Run(CliOptions)
}

///|
fn help_message() -> String {
  let message =
    #|Usage: moonjq [options] <filter> [file...]
    #|
    #|Options:
    #|  -c, --compact-output  Print compact JSON instead of pretty JSON.
    #|  -f, --from-file FILE  Read the filter from FILE.
    #|  -l, --logs            Treat input as newline-delimited JSON logs.
    #|  -n, --null-input      Run the filter once with null input.
    #|  -r, --raw-output      Print strings without JSON quotes.
    #|  -h, --help            Show this help message.
    #|
    #|If no file is provided, stdin is used. Use '-' as a file to read stdin.
    #|The --logs option is a MoonJQ extension for JSONL/NDJSON input.
    #|
    #|Examples:
    #|  moonjq '.foo' data.json
    #|  cat data.json | moonjq -r '.name'
    #|  moonjq -n '{ok: true}'
    #|  moonjq -f filter.jq data.json
    #|  cat logs.ndjson | moonjq --logs -r '.message'
  message
}

///|
fn parse_cli(args : ArrayView[String]) -> CliParseResult {
  let mut logs = false
  let mut raw_output = false
  let mut compact_output = false
  let mut null_input = false
  let mut query_file : String? = None
  let mut index = 0
  while index < args.length() {
    let arg = args[index]
    if arg == "-h" || arg == "--help" {
      return Help
    }
    if arg == "-l" || arg == "--logs" {
      logs = true
      index = index + 1
      continue
    }
    if arg == "-r" || arg == "--raw-output" {
      raw_output = true
      index = index + 1
      continue
    }
    if arg == "-c" || arg == "--compact-output" {
      compact_output = true
      index = index + 1
      continue
    }
    if arg == "-n" || arg == "--null-input" {
      null_input = true
      index = index + 1
      continue
    }
    if arg == "-f" || arg == "--from-file" {
      if index + 1 >= args.length() {
        return Error("Missing path after --from-file")
      }
      if query_file is Some(_) {
        return Error("Multiple filters provided")
      }
      query_file = Some(args[index + 1])
      index = index + 2
      continue
    }
    if arg == "--" {
      index = index + 1
      break
    }
    if arg.has_prefix("-") {
      return Error("Unknown option: \"" + arg + "\"")
    }
    break
  }
  if logs && null_input {
    return Error("--logs cannot be combined with --null-input")
  }
  let query = match query_file {
    Some(path) => QuerySource::File(path)
    None => {
      if index >= args.length() {
        return Error("Missing filter")
      }
      let query_text = args[index]
      index = index + 1
      QuerySource::Inline(query_text)
    }
  }
  let inputs : Array[InputSource] = []
  while index < args.length() {
    let path = args[index]
    if path == "-" {
      inputs.push(Stdin)
    } else {
      inputs.push(File(path))
    }
    index = index + 1
  }
  if inputs.is_empty() && !null_input {
    inputs.push(Stdin)
  }
  Run({ query, inputs, logs, raw_output, compact_output, null_input })
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
    Help => {
      @stdio.stdout.write(help_message())
      return
    }
    Error(msg) => {
      @stdio.stderr.write("moonjq: " + msg + "\n")
      @stdio.stderr.write(help_message())
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
