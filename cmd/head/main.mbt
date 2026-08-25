///|
priv suberror CliError {
  CliError(String)
}

///|
let chunk_size : Int = 65536

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
fn parse_count(text : String) -> Int64 raise CliError {
  let n = @string.parse_int64(text) catch {
    _ => raise CliError("head: invalid count: '\{text}'")
  }
  if n < 0 {
    raise CliError("head: invalid count: '\{text}'")
  }
  n
}

///|
async fn read_chunk(r : &@io.Reader, buf : FixedArray[Byte]) -> Bytes? {
  let n = r.read(buf)
  if n == 0 {
    None
  } else {
    Some(Bytes::from_array(buf[0:n]))
  }
}

///|
/// Stream the first N lines (or bytes) from a reader, stopping as soon as
/// the quota is met so the rest of the input is never read. Binary data
/// passes through unchanged.
async fn head_reader(
  r : &@io.Reader,
  line_count : Int64,
  byte_count : Int64?,
) -> Unit {
  let buf : FixedArray[Byte] = FixedArray::make(chunk_size, 0)
  match byte_count {
    Some(n) => {
      let mut remaining = n
      while remaining > 0 {
        match read_chunk(r, buf) {
          Some(chunk) =>
            if chunk.length().to_int64() <= remaining {
              @stdio.stdout.write(chunk)
              remaining -= chunk.length().to_int64()
            } else {
              @stdio.stdout.write(chunk[0:remaining.to_int()])
              remaining = 0
            }
          None => break
        }
      }
    }
    None => {
      let mut remaining = line_count
      while remaining > 0 {
        match read_chunk(r, buf) {
          Some(chunk) => {
            let mut cut = -1
            for i in 0..<chunk.length() {
              if chunk[i] is b'\n' {
                remaining -= 1
                if remaining == 0 {
                  cut = i + 1
                  break
                }
              }
            }
            if cut >= 0 {
              @stdio.stdout.write(chunk[0:cut])
            } else {
              @stdio.stdout.write(chunk)
            }
          }
          None => break
        }
      }
    }
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
    let byte_count : Int64? = match option_value(matches, "bytes") {
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
      if path == "-" {
        head_reader(@stdio.stdin, line_count, byte_count)
      } else {
        let file = @fs.open(path, mode=ReadOnly)
        defer file.close()
        head_reader(file, line_count, byte_count)
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
