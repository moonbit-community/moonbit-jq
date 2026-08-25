///|
priv suberror CliError {
  CliError(String)
}

///|
priv struct Entry {
  line : String
  key : String
  numeric : Double
  index : Int
}

///|
fn sort_command() -> @argparse.Command {
  Command(
    "sort",
    about="Sort lines of all inputs together.",
    flags=[
      FlagArg("reverse", short='r', about="Reverse the comparison."),
      FlagArg(
        "numeric-sort",
        short='n',
        about="Compare by the numeric prefix of the key.",
      ),
      FlagArg(
        "unique",
        short='u',
        about="Output only the first line of each group of equal keys.",
      ),
      FlagArg(
        "ignore-case",
        short='f',
        about="Fold lower case to upper case when comparing.",
      ),
    ],
    options=[
      OptionArg(
        "key",
        short='k',
        about="Sort by fields START[,END] (1-based, whole fields only).",
      ),
      OptionArg(
        "field-separator",
        short='t',
        about="Field separator for -k (default: runs of blanks).",
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
fn split_fields(line : String, separator : String?) -> Array[String] {
  match separator {
    Some(sep) => line.split(sep).map(v => v.to_owned()).collect()
    None => {
      let fields : Array[String] = []
      let sb = StringBuilder()
      let mut in_field = false
      for c in line {
        if c == ' ' || c == '\t' {
          if in_field {
            fields.push(sb.to_string())
            sb.reset()
            in_field = false
          }
        } else {
          sb.write_char(c)
          in_field = true
        }
      }
      if in_field {
        fields.push(sb.to_string())
      }
      fields
    }
  }
}

///|
fn parse_positive(text : StringView, spec : String) -> Int raise CliError {
  let n = @string.parse_int(text) catch {
    _ => raise CliError("sort: invalid key specification: '\{spec}'")
  }
  if n < 1 {
    raise CliError("sort: invalid key specification: '\{spec}'")
  }
  n
}

///|
fn parse_key(spec : String) -> (Int, Int) raise CliError {
  let pieces : Array[String] = spec.split(",").map(v => v.to_owned()).collect()
  match pieces {
    [a] => {
      let start = parse_positive(a, spec)
      (start, 0x7FFFFFFF)
    }
    [a, b] => {
      let start = parse_positive(a, spec)
      let end = parse_positive(b, spec)
      if start > end {
        raise CliError("sort: invalid key specification: '\{spec}'")
      }
      (start, end)
    }
    _ => raise CliError("sort: invalid key specification: '\{spec}'")
  }
}

///|
fn extract_key(
  line : String,
  key : (Int, Int)?,
  separator : String?,
  out_sep : String,
) -> String {
  match key {
    None => line
    Some((start, end)) => {
      let fields = split_fields(line, separator)
      let kept : Array[String] = []
      for index, field in fields {
        let position = index + 1
        if position >= start && position <= end {
          kept.push(field)
        }
      }
      kept.join(out_sep)
    }
  }
}

///|
/// Parse the leading numeric prefix (optional sign, digits, optional decimal
/// part) of a key, ignoring leading blanks. Lines without one sort as 0.
fn numeric_prefix(key : String) -> Double {
  let chars : Array[Char] = key.iter().collect()
  let mut start = 0
  while start < chars.length() && (chars[start] == ' ' || chars[start] == '\t') {
    start += 1
  }
  let sb = StringBuilder()
  let mut i = start
  if i < chars.length() && (chars[i] == '-' || chars[i] == '+') {
    sb.write_char(chars[i])
    i += 1
  }
  let mut saw_digit = false
  while i < chars.length() && chars[i] is ('0'..='9') {
    sb.write_char(chars[i])
    saw_digit = true
    i += 1
  }
  if i < chars.length() && chars[i] == '.' {
    sb.write_char('.')
    i += 1
    while i < chars.length() && chars[i] is ('0'..='9') {
      sb.write_char(chars[i])
      saw_digit = true
      i += 1
    }
  }
  if !saw_digit {
    return 0.0
  }
  @string.parse_double(sb.to_string()) catch {
    _ => 0.0
  }
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
  let command = sort_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let reverse = matches.flags.get_or_default("reverse", false)
  let numeric = matches.flags.get_or_default("numeric-sort", false)
  let unique = matches.flags.get_or_default("unique", false)
  let fold_case = matches.flags.get_or_default("ignore-case", false)
  let separator = match option_value(matches, "field-separator") {
    Some(sep) => {
      if sep.char_length() != 1 {
        @stdio.stderr.write(
          "sort: the field separator must be a single character\n",
        )
        @sys.exit(2)
        return
      }
      Some(sep)
    }
    None => None
  }
  let key_spec = try {
    match option_value(matches, "key") {
      Some(spec) => Some(parse_key(spec))
      None => None
    }
  } catch {
    CliError(msg) => {
      @stdio.stderr.write("\{msg}\n")
      @sys.exit(2)
      return
    }
  }
  let out_sep = match separator {
    Some(sep) => sep
    None => " "
  }
  let files = matches.values.get("files").unwrap_or([])
  let sources = if files.is_empty() { ["-"] } else { files }
  let lines : Array[String] = []
  for path in sources {
    let text = read_source_text(path) catch {
      err => {
        @stdio.stderr.write("sort: \{err}\n")
        @sys.exit(1)
        return
      }
    }
    lines.append(split_lines(text))
  }
  let entries : Array[Entry] = []
  for index, line in lines {
    let raw_key = extract_key(line, key_spec, separator, out_sep)
    let key = if fold_case { raw_key.to_lower() } else { raw_key }
    entries.push({
      line,
      key,
      numeric: if numeric {
        numeric_prefix(key)
      } else {
        0.0
      },
      index,
    })
  }
  fn key_compare(a : Entry, b : Entry) -> Int {
    if numeric {
      a.numeric.compare(b.numeric)
    } else {
      a.key.compare(b.key)
    }
  }

  entries.sort_by(fn(a, b) {
    let mut cmp = key_compare(a, b)
    if cmp == 0 {
      // Last-resort comparison on the whole line, like GNU sort.
      cmp = a.line.compare(b.line)
    }
    if reverse {
      cmp = -cmp
    }
    if cmp == 0 {
      // Stability tiebreak: sort_by itself is unstable.
      a.index - b.index
    } else {
      cmp
    }
  })
  let mut previous : Entry? = None
  for entry in entries {
    let emit = match previous {
      Some(prev) => if unique { key_compare(prev, entry) != 0 } else { true }
      None => true
    }
    if emit {
      @stdio.stdout.write(entry.line + "\n")
      previous = Some(entry)
    }
  }
}
