///|
priv suberror CliError {
  CliError(String)
}

///|
fn base64_command() -> @argparse.Command {
  Command(
    "base64",
    about="Base64 encode or decode a file or stdin.",
    flags=[FlagArg("decode", short='d', about="Decode instead of encode.")],
    options=[
      OptionArg(
        "wrap",
        short='w',
        about="Wrap encoded lines after N characters (0 disables; default 76).",
        default_values=["76"],
      ),
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
fn b64_char(v : Int) -> Char {
  if v < 26 {
    (0x41 + v).unsafe_to_char()
  } else if v < 52 {
    (0x61 + v - 26).unsafe_to_char()
  } else if v < 62 {
    (0x30 + v - 52).unsafe_to_char()
  } else if v == 62 {
    '+'
  } else {
    '/'
  }
}

///|
fn sextet(c : Char) -> Int raise CliError {
  match c {
    'A'..='Z' => c.to_int() - 0x41
    'a'..='z' => c.to_int() - 0x61 + 26
    '0'..='9' => c.to_int() - 0x30 + 52
    '+' => 62
    '/' => 63
    _ => raise CliError("base64: invalid input character: '\{c}'")
  }
}

///|
fn encode(data : Bytes, wrap : Int) -> String {
  let sb = StringBuilder()
  let mut column = 0
  fn emit(c : Char) {
    sb.write_char(c)
    column += 1
    if wrap > 0 && column == wrap {
      sb.write_char('\n')
      column = 0
    }
  }

  let mut i = 0
  while i < data.length() {
    let b0 = data[i].to_int()
    let b1 = if i + 1 < data.length() { data[i + 1].to_int() } else { 0 }
    let b2 = if i + 2 < data.length() { data[i + 2].to_int() } else { 0 }
    let n = (b0 << 16) | (b1 << 8) | b2
    emit(b64_char((n >> 18) & 0x3F))
    emit(b64_char((n >> 12) & 0x3F))
    if i + 1 < data.length() {
      emit(b64_char((n >> 6) & 0x3F))
    } else {
      emit('=')
    }
    if i + 2 < data.length() {
      emit(b64_char(n & 0x3F))
    } else {
      emit('=')
    }
    i += 3
  }
  let text = sb.to_string()
  if text is "" {
    ""
  } else if text.has_suffix("\n") {
    text
  } else {
    text + "\n"
  }
}

///|
fn decode(text : String) -> Bytes raise CliError {
  let cleaned : Array[Char] = []
  for c in text {
    if c is (' ' | '\t' | '\n' | '\r') {
      continue
    }
    cleaned.push(c)
  }
  if cleaned.length() % 4 != 0 {
    raise CliError("base64: invalid input length")
  }
  let out : Array[Byte] = []
  let mut i = 0
  while i < cleaned.length() {
    let last_quad = i + 4 == cleaned.length()
    let c0 = cleaned[i]
    let c1 = cleaned[i + 1]
    let c2 = cleaned[i + 2]
    let c3 = cleaned[i + 3]
    if c0 == '=' || c1 == '=' {
      raise CliError("base64: invalid padding")
    }
    if (c2 == '=' || c3 == '=') && !last_quad {
      raise CliError("base64: invalid padding")
    }
    if c2 == '=' && c3 != '=' {
      raise CliError("base64: invalid padding")
    }
    let v0 = sextet(c0)
    let v1 = sextet(c1)
    let v2 = if c2 == '=' { 0 } else { sextet(c2) }
    let v3 = if c3 == '=' { 0 } else { sextet(c3) }
    let n = (v0 << 18) | (v1 << 12) | (v2 << 6) | v3
    out.push(((n >> 16) & 0xFF).to_byte())
    if c2 != '=' {
      out.push(((n >> 8) & 0xFF).to_byte())
    }
    if c3 != '=' {
      out.push((n & 0xFF).to_byte())
    }
    i += 4
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
  let command = base64_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let decode_mode = matches.flags.get_or_default("decode", false)
  let wrap_text = option_value(matches, "wrap").unwrap_or("76")
  let wrap = @string.parse_int(wrap_text) catch {
    _ => {
      @stdio.stderr.write("base64: invalid wrap size: '\{wrap_text}'\n")
      @sys.exit(2)
      return
    }
  }
  if wrap < 0 {
    @stdio.stderr.write("base64: invalid wrap size: '\{wrap_text}'\n")
    @sys.exit(2)
    return
  }
  let inputs = matches.values.get("input").unwrap_or([])
  let path = if inputs.is_empty() { "-" } else { inputs[0] }
  try {
    if decode_mode {
      @stdio.stdout.write(decode(read_source_text(path)))
    } else {
      @stdio.stdout.write(encode(read_source_bytes(path), wrap))
    }
  } catch {
    CliError(msg) => {
      @stdio.stderr.write("\{msg}\n")
      @sys.exit(1)
      return
    }
    err => {
      @stdio.stderr.write("base64: \{err}\n")
      @sys.exit(1)
      return
    }
  }
}
