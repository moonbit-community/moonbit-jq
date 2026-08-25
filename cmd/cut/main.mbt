///|
priv suberror CliError {
  CliError(String)
}

///|
let open_end : Int = 0x7FFFFFFF

///|
fn cut_command() -> @argparse.Command {
  Command(
    "cut",
    about="Print selected fields or characters of each line.",
    flags=[
      FlagArg(
        "only-delimited",
        short='s',
        about="Skip lines without the delimiter (field mode).",
      ),
    ],
    options=[
      OptionArg(
        "delimiter",
        short='d',
        about="Field delimiter character (default TAB).",
      ),
      OptionArg(
        "fields",
        short='f',
        about="Comma-separated field list, e.g. 1,3-5,7-.",
        allow_hyphen_values=true,
      ),
      OptionArg(
        "characters",
        short='c',
        about="Comma-separated character position list.",
        conflicts_with=["fields"],
        allow_hyphen_values=true,
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
fn parse_positive(text : String, spec : String) -> Int raise CliError {
  let n = @string.parse_int(text) catch {
    _ => raise CliError("cut: invalid list: '\{spec}'")
  }
  if n < 1 {
    raise CliError("cut: list positions are numbered from 1: '\{spec}'")
  }
  n
}

///|
fn parse_list(spec : String) -> Array[(Int, Int)] raise CliError {
  let ranges : Array[(Int, Int)] = []
  for part in spec.split(",") {
    let item = part.to_owned()
    if item is "" {
      raise CliError("cut: invalid list: '\{spec}'")
    }
    let pieces : Array[String] = item
      .split("-")
      .map(v => v.to_owned())
      .collect()
    match pieces {
      [n] => {
        let v = parse_positive(n, spec)
        ranges.push((v, v))
      }
      ["", ""] => raise CliError("cut: invalid list: '\{spec}'")
      [a, b] => {
        let lo = if a is "" { 1 } else { parse_positive(a, spec) }
        let hi = if b is "" { open_end } else { parse_positive(b, spec) }
        if lo > hi {
          raise CliError("cut: invalid decreasing range: '\{spec}'")
        }
        ranges.push((lo, hi))
      }
      _ => raise CliError("cut: invalid list: '\{spec}'")
    }
  }
  if ranges.is_empty() {
    raise CliError("cut: invalid list: '\{spec}'")
  }
  ranges
}

///|
fn selected(ranges : Array[(Int, Int)], index : Int) -> Bool {
  for r in ranges {
    let (lo, hi) = r
    if index >= lo && index <= hi {
      return true
    }
  }
  false
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
fn cut_fields(
  line : String,
  ranges : Array[(Int, Int)],
  delimiter : String,
  only_delimited : Bool,
) -> String? {
  let parts : Array[String] = line
    .split(delimiter)
    .map(v => v.to_owned())
    .collect()
  if parts.length() == 1 {
    // No delimiter in this line.
    if only_delimited {
      return None
    }
    return Some(line)
  }
  let kept : Array[String] = []
  for index, part in parts {
    if selected(ranges, index + 1) {
      kept.push(part)
    }
  }
  Some(kept.join(delimiter))
}

///|
fn cut_characters(line : String, ranges : Array[(Int, Int)]) -> String {
  let sb = StringBuilder()
  let mut index = 1
  for c in line {
    if selected(ranges, index) {
      sb.write_char(c)
    }
    index += 1
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
  let command = cut_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let only_delimited = matches.flags.get_or_default("only-delimited", false)
  let delimiter = match option_value(matches, "delimiter") {
    Some(d) => {
      if d.length() != 1 {
        @stdio.stderr.write("cut: the delimiter must be a single character\n")
        @sys.exit(2)
        return
      }
      d
    }
    None => "\t"
  }
  let fields_spec = option_value(matches, "fields")
  let chars_spec = option_value(matches, "characters")
  if fields_spec is None && chars_spec is None {
    @stdio.stderr.write(
      "cut: you must specify a list of fields (-f) or characters (-c)\n",
    )
    @sys.exit(2)
    return
  }
  let (field_ranges, char_ranges) = try {
    let field_ranges = match fields_spec {
      Some(spec) => Some(parse_list(spec))
      None => None
    }
    let char_ranges = match chars_spec {
      Some(spec) => Some(parse_list(spec))
      None => None
    }
    (field_ranges, char_ranges)
  } catch {
    CliError(msg) => {
      @stdio.stderr.write("\{msg}\n")
      @sys.exit(2)
      return
    }
  }
  let files = matches.values.get("files").unwrap_or([])
  let sources = if files.is_empty() { ["-"] } else { files }
  let mut failed = false
  for path in sources {
    let text = read_source_text(path) catch {
      err => {
        @stdio.stderr.write("cut: \{err}\n")
        failed = true
        continue
      }
    }
    for line in split_lines(text) {
      match field_ranges {
        Some(ranges) =>
          match cut_fields(line, ranges, delimiter, only_delimited) {
            Some(out) => @stdio.stdout.write(out + "\n")
            None => ()
          }
        None =>
          match char_ranges {
            Some(ranges) =>
              @stdio.stdout.write(cut_characters(line, ranges) + "\n")
            None => ()
          }
      }
    }
  }
  if failed {
    @sys.exit(1)
  }
}
