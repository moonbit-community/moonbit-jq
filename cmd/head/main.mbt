///|
priv suberror CliError {
  CliError(String)
}

///|
fn head_command() -> @argparse.Command {
  Command(
    "head",
    about="Print the first lines (or bytes) of each input.",
    flags=[
      FlagArg("quiet", short='q', about="Never print file name headers."),
      FlagArg("verbose", short='v', about="Always print file name headers."),
    ],
    options=[
      OptionArg(
        "lines",
        short='n',
        about="Print the first N lines (default 10).",
      ),
      OptionArg("bytes", short='c', about="Print the first N bytes.", conflicts_with=[
        "lines",
      ]),
    ],
    positionals=[
      PositionArg(
        "files",
        about="[file...] ('-' or no file reads stdin)",
        num_args=ValueRange(lower=0),
      ),
    ],
    disable_help_subcommand=true,
  )
}

///|
fn option_value(matches : @argparse.Matches, name : String) -> String? {
  match matches.values.get(name) {
    Some(vals) =>
      if vals.is_empty() {
        None
      } else {
        Some(vals[vals.length() - 1])
      }
    None => None
  }
}

///|
fn parse_count(text : String) -> Int raise CliError {
  let n = @string.parse_int(text) catch {
    _ => raise CliError("head: invalid count: '\{text}'")
  }
  if n < 0 {
    raise CliError("head: invalid count: '\{text}'")
  }
  n
}

///|
/// Take the first n lines as raw bytes so that binary or invalid-UTF-8 data
/// passes through unchanged; a line ends at '\n' or at end of input.
fn take_lines(data : Bytes, n : Int) -> BytesView {
  if n <= 0 {
    return data[0:0]
  }
  let mut seen = 0
  for i in 0..<data.length() {
    if data[i] is b'\n' {
      seen += 1
      if seen == n {
        return data[0:i + 1]
      }
    }
  }
  data
}

///|
async fn read_source_bytes(path : String) -> Bytes {
  if path == "-" {
    @stdio.stdin.read_all().binary()
  } else {
    @fs.read_file_to_bytes(path)
  }
}

///|
async fn main {
  let args = @env.args()[1:]
  let command = head_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let quiet = matches.flags.get_or_default("quiet", false)
  let verbose = matches.flags.get_or_default("verbose", false)
  let (line_count, byte_count) = try {
    let byte_count : Int? = match option_value(matches, "bytes") {
      Some(text) => Some(parse_count(text))
      None => None
    }
    let line_count = match option_value(matches, "lines") {
      Some(text) => parse_count(text)
      None => 10
    }
    (line_count, byte_count)
  } catch {
    CliError(msg) => {
      @stdio.stderr.write("\{msg}\n")
      @sys.exit(2)
      return
    }
  }
  let files = matches.values.get("files").unwrap_or([])
  let sources = if files.is_empty() { ["-"] } else { files }
  let show_headers = (sources.length() > 1 || verbose) && !quiet
  let mut failed = false
  for index, path in sources {
    if show_headers {
      let name = if path == "-" { "standard input" } else { path }
      let prefix = if index > 0 { "\n" } else { "" }
      @stdio.stdout.write("\{prefix}==> \{name} <==\n")
    }
    try {
      let data = read_source_bytes(path)
      match byte_count {
        Some(n) => {
          let take = if n < data.length() { n } else { data.length() }
          @stdio.stdout.write(data[0:take])
        }
        None => @stdio.stdout.write(take_lines(data, line_count))
      }
    } catch {
      err => {
        @stdio.stderr.write("head: \{err}\n")
        failed = true
      }
    }
  }
  if failed {
    @sys.exit(1)
  }
}
