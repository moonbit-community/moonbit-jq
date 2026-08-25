///|
priv suberror CliError {
  CliError(String)
}

///|
fn xxd_command() -> @argparse.Command {
  Command(
    "xxd",
    about="Make a hex dump, or reverse one back into bytes.",
    flags=[
      FlagArg("plain", short='p', about="Plain continuous hex dump."),
      FlagArg("reverse", short='r', about="Convert a hex dump back into bytes."),
    ],
    options=[
      OptionArg(
        "cols",
        short='c',
        about="Bytes per line (default 16, or 30 with -p).",
      ),
      OptionArg("len", short='l', about="Stop after N input bytes."),
    ],
    positionals=[
      PositionArg(
        "input",
        about="[file] ('-' or no file reads stdin)",
        num_args=ValueRange(lower=0, upper=1),
      ),
    ],
    disable_help_subcommand=true,
  )
}

///|
fn hex_digit(n : Int) -> Char {
  if n < 10 {
    (0x30 + n).unsafe_to_char()
  } else {
    (0x61 + n - 10).unsafe_to_char()
  }
}

///|
fn write_hex_byte(sb : StringBuilder, b : Byte) -> Unit {
  sb.write_char(hex_digit(b.to_int() >> 4))
  sb.write_char(hex_digit(b.to_int() & 0xF))
}

///|
fn hex_val(c : Char) -> Int {
  match c {
    '0'..='9' => c.to_int() - 0x30
    'a'..='f' => c.to_int() - 0x61 + 10
    'A'..='F' => c.to_int() - 0x41 + 10
    _ => -1
  }
}

///|
fn dump(data : BytesView, cols : Int) -> String {
  let sb = StringBuilder()
  let mut offset = 0
  while offset < data.length() {
    for k in 0..<8 {
      sb.write_char(hex_digit((offset >> ((7 - k) * 4)) & 0xF))
    }
    sb.write_string(": ")
    let line_end = if offset + cols < data.length() {
      offset + cols
    } else {
      data.length()
    }
    for i in 0..<cols {
      if i > 0 && i % 2 == 0 {
        sb.write_char(' ')
      }
      if offset + i < line_end {
        write_hex_byte(sb, data[offset + i])
      } else {
        sb.write_string("  ")
      }
    }
    sb.write_string("  ")
    for i in offset..<line_end {
      let code = data[i].to_int()
      if code >= 0x20 && code <= 0x7E {
        sb.write_char(code.unsafe_to_char())
      } else {
        sb.write_char('.')
      }
    }
    sb.write_char('\n')
    offset += cols
  }
  sb.to_string()
}

///|
fn dump_plain(data : BytesView, cols : Int) -> String {
  let sb = StringBuilder()
  for index, b in data {
    write_hex_byte(sb, b)
    if (index + 1) % cols == 0 {
      sb.write_char('\n')
    }
  }
  if data.length() > 0 && data.length() % cols != 0 {
    sb.write_char('\n')
  }
  sb.to_string()
}

///|
fn reverse_plain(text : String) -> Bytes raise CliError {
  let out : Array[Byte] = []
  let mut high = -1
  for c in text {
    if c is (' ' | '\t' | '\n' | '\r') {
      continue
    }
    let v = hex_val(c)
    if v < 0 {
      raise CliError("xxd: invalid hex character: '\{c}'")
    }
    if high < 0 {
      high = v
    } else {
      out.push(((high << 4) | v).to_byte())
      high = -1
    }
  }
  if high >= 0 {
    raise CliError("xxd: odd number of hex digits")
  }
  Bytes::from_array(out)
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
/// Parse hex byte pairs from the region after the "offset:" column of a
/// standard xxd dump line. Hex groups are separated by single spaces; the
/// ASCII column is separated by at least two spaces, which ends the scan.
fn reverse_dump(text : String) -> Bytes {
  let out : Array[Byte] = []
  for line in split_lines(text) {
    let chars : Array[Char] = line.iter().collect()
    let mut i = 0
    while i < chars.length() && chars[i] != ':' {
      i += 1
    }
    if i >= chars.length() {
      continue
    }
    i += 1
    while i < chars.length() {
      if chars[i] == ' ' {
        if i + 1 < chars.length() && chars[i + 1] == ' ' {
          break
        }
        i += 1
        continue
      }
      if i + 1 >= chars.length() {
        break
      }
      let high = hex_val(chars[i])
      let low = hex_val(chars[i + 1])
      if high < 0 || low < 0 {
        break
      }
      out.push(((high << 4) | low).to_byte())
      i += 2
    }
  }
  Bytes::from_array(out)
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
fn parse_number(
  matches : @argparse.Matches,
  name : String,
  minimum? : Int = 1,
) -> Int? raise CliError {
  match option_value(matches, name) {
    Some(text) => {
      let n = @string.parse_int(text) catch {
        _ => raise CliError("xxd: invalid -\{name} value: '\{text}'")
      }
      if n < minimum {
        raise CliError("xxd: invalid -\{name} value: '\{text}'")
      }
      Some(n)
    }
    None => None
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
  let command = xxd_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let plain = matches.flags.get_or_default("plain", false)
  let reverse = matches.flags.get_or_default("reverse", false)
  let (cols_opt, len_opt) = (
    parse_number(matches, "cols"),
    parse_number(matches, "len", minimum=0),
  ) catch {
    CliError(msg) => {
      @stdio.stderr.write("\{msg}\n")
      @sys.exit(2)
      return
    }
  }
  let cols = match cols_opt {
    Some(n) => n
    None => if plain { 30 } else { 16 }
  }
  let inputs = matches.values.get("input").unwrap_or([])
  let path = if inputs.is_empty() { "-" } else { inputs[0] }
  try {
    if reverse {
      let text = read_source_text(path)
      let bytes = if plain { reverse_plain(text) } else { reverse_dump(text) }
      @stdio.stdout.write(bytes)
    } else {
      let data = read_source_bytes(path)
      let limit = match len_opt {
        Some(n) => if n < data.length() { n } else { data.length() }
        None => data.length()
      }
      let view = data[0:limit]
      let rendered = if plain {
        dump_plain(view, cols)
      } else {
        dump(view, cols)
      }
      @stdio.stdout.write(rendered)
    }
  } catch {
    CliError(msg) => {
      @stdio.stderr.write("\{msg}\n")
      @sys.exit(1)
      return
    }
    err => {
      @stdio.stderr.write("xxd: \{err}\n")
      @sys.exit(1)
      return
    }
  }
}
