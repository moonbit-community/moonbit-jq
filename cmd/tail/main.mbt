///|
priv suberror CliError {
  CliError(String)
}

///|
/// `Last(n)` selects the final n units; `FromStart(k)` selects from the k-th
/// unit (1-based) to the end, mirroring tail's `-n +K` syntax.
priv enum CountSpec {
  Last(Int)
  FromStart(Int)
}

///|
fn tail_command() -> @argparse.Command {
  Command(
    "tail",
    about="Print the last lines (or bytes) of each input.",
    flags=[
      FlagArg("quiet", short='q', about="Never print file name headers."),
      FlagArg("verbose", short='v', about="Always print file name headers."),
    ],
    options=[
      OptionArg(
        "lines",
        short='n',
        about="Print the last N lines, or from line +N (default 10).",
        allow_hyphen_values=true,
      ),
      OptionArg(
        "bytes",
        short='c',
        about="Print the last N bytes, or from byte +N.",
        conflicts_with=["lines"],
      ),
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
fn parse_spec(text : String) -> CountSpec raise CliError {
  let (from_start, digits) = if text is ['+', .. rest] {
    (true, rest)
  } else {
    (false, text)
  }
  let n = @string.parse_int(digits) catch {
    _ => raise CliError("tail: invalid count: '\{text}'")
  }
  if n < 0 {
    raise CliError("tail: invalid count: '\{text}'")
  }
  if from_start {
    FromStart(if n < 1 { 1 } else { n })
  } else {
    Last(n)
  }
}

///|
/// Select lines as raw bytes so binary or invalid-UTF-8 data passes through
/// unchanged. A trailing newline terminates the final line rather than
/// starting an empty one.
fn select_lines(data : Bytes, spec : CountSpec) -> BytesView {
  match spec {
    Last(n) => {
      if n <= 0 || data.length() == 0 {
        return data[0:0]
      }
      // Scan backward; the trailing newline (if any) does not count as a
      // line boundary of its own.
      let mut i = if data[data.length() - 1] is b'\n' {
        data.length() - 2
      } else {
        data.length() - 1
      }
      let mut newlines = 0
      while i >= 0 {
        if data[i] is b'\n' {
          newlines += 1
          if newlines == n {
            return data[i + 1:]
          }
        }
        i -= 1
      }
      data
    }
    FromStart(k) => {
      if k <= 1 {
        return data
      }
      let mut seen = 0
      for i in 0..<data.length() {
        if data[i] is b'\n' {
          seen += 1
          if seen == k - 1 {
            return data[i + 1:]
          }
        }
      }
      data[data.length():]
    }
  }
}

///|
fn select_bytes(data : Bytes, spec : CountSpec) -> BytesView {
  match spec {
    Last(n) => {
      let start = if n >= data.length() { 0 } else { data.length() - n }
      data[start:]
    }
    FromStart(k) => {
      let start = if k - 1 > data.length() { data.length() } else { k - 1 }
      data[start:]
    }
  }
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
  let command = tail_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let quiet = matches.flags.get_or_default("quiet", false)
  let verbose = matches.flags.get_or_default("verbose", false)
  let (line_spec, byte_spec) = try {
    let byte_spec : CountSpec? = match option_value(matches, "bytes") {
      Some(text) => Some(parse_spec(text))
      None => None
    }
    let line_spec = match option_value(matches, "lines") {
      Some(text) => parse_spec(text)
      None => Last(10)
    }
    (line_spec, byte_spec)
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
      match byte_spec {
        Some(spec) => @stdio.stdout.write(select_bytes(data, spec))
        None => @stdio.stdout.write(select_lines(data, line_spec))
      }
    } catch {
      err => {
        @stdio.stderr.write("tail: \{err}\n")
        failed = true
      }
    }
  }
  if failed {
    @sys.exit(1)
  }
}
