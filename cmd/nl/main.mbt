///|
fn nl_command() -> @argparse.Command {
  Command(
    "nl",
    about="Number lines of each input.",
    options=[
      OptionArg(
        "body-numbering",
        short='b',
        about="Numbering style: a (all lines), t (nonempty lines), n (none).",
        default_values=["t"],
      ),
      OptionArg(
        "number-width",
        short='w',
        about="Width of the line number column.",
        default_values=["6"],
      ),
      OptionArg(
        "number-separator",
        short='s',
        about="String between number and line.",
        default_values=["\t"],
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
fn option_value(
  matches : @argparse.Matches,
  name : String,
  fallback : String,
) -> String {
  match matches.values.get(name) {
    Some(vals) =>
      if vals.is_empty() {
        fallback
      } else {
        vals[vals.length() - 1]
      }
    None => fallback
  }
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
fn pad_left(text : String, width : Int) -> String {
  let sb = StringBuilder()
  for _ in 0..<(width - text.length()) {
    sb.write_char(' ')
  }
  sb.write_string(text)
  sb.to_string()
}

///|
fn spaces(width : Int) -> String {
  let sb = StringBuilder()
  for _ in 0..<width {
    sb.write_char(' ')
  }
  sb.to_string()
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
  let command = nl_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let style = option_value(matches, "body-numbering", "t")
  if !(style is ("a" | "t" | "n")) {
    @stdio.stderr.write("nl: invalid body numbering style: '\{style}'\n")
    @sys.exit(2)
    return
  }
  let width_text = option_value(matches, "number-width", "6")
  let width = @string.parse_int(width_text) catch {
    _ => {
      @stdio.stderr.write(
        "nl: invalid line number field width: '\{width_text}'\n",
      )
      @sys.exit(2)
      return
    }
  }
  if width < 1 {
    @stdio.stderr.write(
      "nl: invalid line number field width: '\{width_text}'\n",
    )
    @sys.exit(2)
    return
  }
  let separator = option_value(matches, "number-separator", "\t")
  let files = matches.values.get("files").unwrap_or([])
  let sources = if files.is_empty() { ["-"] } else { files }
  let mut number = 1
  let mut failed = false
  for path in sources {
    let text = read_source_text(path) catch {
      err => {
        @stdio.stderr.write("nl: \{err}\n")
        failed = true
        continue
      }
    }
    for line in split_lines(text) {
      let numbered = match style {
        "a" => true
        "t" => line != ""
        _ => false
      }
      if numbered {
        @stdio.stdout.write(
          pad_left(number.to_string(), width) + separator + line + "\n",
        )
        number += 1
      } else {
        @stdio.stdout.write(spaces(width) + line + "\n")
      }
    }
  }
  if failed {
    @sys.exit(1)
  }
}
