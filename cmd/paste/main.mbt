///|
fn paste_command() -> @argparse.Command {
  Command(
    "paste",
    about="Merge corresponding lines of each input.",
    flags=[
      FlagArg(
        "serial",
        short='s',
        about="Paste one file at a time instead of in parallel.",
      ),
    ],
    options=[
      OptionArg(
        "delimiters",
        short='d',
        about="Reuse characters from LIST instead of TAB (\\t, \\n, \\0, \\\\ supported).",
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
fn parse_delimiters(spec : String) -> Array[String] {
  let delims : Array[String] = []
  let chars : Array[Char] = spec.iter().collect()
  let mut i = 0
  while i < chars.length() {
    if chars[i] == '\\' && i + 1 < chars.length() {
      let out = match chars[i + 1] {
        'n' => "\n"
        't' => "\t"
        '0' => ""
        '\\' => "\\"
        c => c.to_string()
      }
      delims.push(out)
      i += 2
    } else {
      delims.push(chars[i].to_string())
      i += 1
    }
  }
  if delims.is_empty() {
    delims.push("\t")
  }
  delims
}

///|
fn split_lines(text : String) -> Array[String] {
  if text is "" {
    return []
  }
  let lines : Array[String] = text.split("\n").map(v => v.to_owned()).collect()
  if text.has_suffix("\n") {
    ignore(lines.pop())
  }
  lines
}

///|
async fn read_source_text(path : String) -> String {
  if path == "-" {
    @stdio.stdin.read_all().text()
  } else {
    @fs.read_file_to_string(path)
  }
}

///|
async fn main {
  let args = @env.args()[1:]
  let command = paste_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let serial = matches.flags.get_or_default("serial", false)
  let delims = match option_value(matches, "delimiters") {
    Some(spec) => parse_delimiters(spec)
    None => ["\t"]
  }
  let files = matches.values.get("files").unwrap_or([])
  let sources = if files.is_empty() { ["-"] } else { files }
  let contents : Array[Array[String]] = []
  for path in sources {
    let text = read_source_text(path) catch {
      err => {
        @stdio.stderr.write("paste: \{err}\n")
        @sys.exit(1)
        return
      }
    }
    contents.push(split_lines(text))
  }
  if serial {
    for lines in contents {
      let sb = StringBuilder()
      for index, line in lines {
        if index > 0 {
          sb.write_string(delims[(index - 1) % delims.length()])
        }
        sb.write_string(line)
      }
      sb.write_string("\n")
      @stdio.stdout.write(sb.to_string())
    }
  } else {
    let mut rows = 0
    for lines in contents {
      if lines.length() > rows {
        rows = lines.length()
      }
    }
    for row in 0..<rows {
      let sb = StringBuilder()
      for index, lines in contents {
        if index > 0 {
          sb.write_string(delims[(index - 1) % delims.length()])
        }
        if row < lines.length() {
          sb.write_string(lines[row])
        }
      }
      sb.write_string("\n")
      @stdio.stdout.write(sb.to_string())
    }
  }
}
