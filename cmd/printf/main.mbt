///|
priv struct Ctx {
  out : Array[Byte]
  args : Array[String]
  mut arg_index : Int
  warnings : Array[String]
  mut stop : Bool
  mut fatal : String?
}

///|
fn help_message() -> String {
  let message =
    #|Usage: printf FORMAT [ARGUMENT...]
    #|
    #|Format and print ARGUMENTs under control of FORMAT, like printf(1).
    #|The FORMAT is reused as necessary to consume all arguments.
    #|
    #|Escapes: \a \b \e \f \n \r \t \v \\ \" \' \NNN \0NNN \xHH \uHHHH
    #|\UHHHHHHHH, and \c (stop all output).
    #|
    #|Conversions: %s %c %b %d %i %u %o %x %X %f %e %E %g %G %%, with the
    #|flags -+ 0#, field width, and precision (both accept *).
    #|%b interprets escapes in its argument.
    #|
    #|Use -- before a FORMAT that starts with '-'.
  message
}

///|
fn Ctx::next_arg(self : Ctx) -> String? {
  if self.arg_index < self.args.length() {
    let value = self.args[self.arg_index]
    self.arg_index += 1
    Some(value)
  } else {
    None
  }
}

///|
fn Ctx::warn(self : Ctx, msg : String) -> Unit {
  self.warnings.push(msg)
}

///|
/// Parse a printf numeric argument: optional blanks, 'C or "C for a character
/// code, otherwise decimal, 0x hex, or leading-0 octal with optional sign.
fn parse_int_arg(ctx : Ctx, text : String) -> Int64 {
  let chars : Array[Char] = text.iter().collect()
  let mut i = 0
  while i < chars.length() && (chars[i] == ' ' || chars[i] == '\t') {
    i += 1
  }
  if i >= chars.length() {
    return 0
  }
  if chars[i] == '\'' || chars[i] == '"' {
    return if i + 1 < chars.length() {
      chars[i + 1].to_int().to_int64()
    } else {
      0
    }
  }
  let mut neg = false
  if chars[i] == '+' || chars[i] == '-' {
    neg = chars[i] == '-'
    i += 1
  }
  let sb = StringBuilder()
  for k in i..<chars.length() {
    sb.write_char(chars[k])
  }
  let rest = sb.to_string()
  let value : Int64 = try {
    if rest.has_prefix("0x") || rest.has_prefix("0X") {
      @string.parse_uint64(rest, base=16).reinterpret_as_int64()
    } else if rest.has_prefix("0") && rest.length() > 1 {
      @string.parse_uint64(rest, base=8).reinterpret_as_int64()
    } else {
      @string.parse_uint64(rest, base=10).reinterpret_as_int64()
    }
  } catch {
    _ => {
      ctx.warn("printf: '\{text}': expected a numeric value")
      0
    }
  }
  if neg {
    -value
  } else {
    value
  }
}

///|
fn parse_double_arg(ctx : Ctx, text : String) -> Double {
  let chars : Array[Char] = text.iter().collect()
  let mut i = 0
  while i < chars.length() && (chars[i] == ' ' || chars[i] == '\t') {
    i += 1
  }
  if i >= chars.length() {
    return 0.0
  }
  if chars[i] == '\'' || chars[i] == '"' {
    return if i + 1 < chars.length() {
      chars[i + 1].to_int().to_double()
    } else {
      0.0
    }
  }
  let sb = StringBuilder()
  for k in i..<chars.length() {
    sb.write_char(chars[k])
  }
  @string.parse_double(sb.to_string()) catch {
    _ => {
      ctx.warn("printf: '\{text}': expected a numeric value")
      0.0
    }
  }
}

///|
fn emit_signed(
  ctx : Ctx,
  n : Int64,
  width : Int?,
  prec : Int?,
  minus : Bool,
  plus : Bool,
  space : Bool,
  zero : Bool,
) -> Unit {
  let negf = n < 0
  let mag = if negf {
    (-n).reinterpret_as_uint64()
  } else {
    n.reinterpret_as_uint64()
  }
  let body = apply_precision(mag.to_string(), prec)
  let sign = if negf {
    "-"
  } else if plus {
    "+"
  } else if space {
    " "
  } else {
    ""
  }
  let zero_eff = zero && !minus && prec is None
  push_string_utf8(ctx.out, pad_field(sign, body, width, minus, zero_eff))
}

///|
fn emit_unsigned(
  ctx : Ctx,
  u : UInt64,
  radix : Int,
  upper : Bool,
  alt : Bool,
  width : Int?,
  prec : Int?,
  minus : Bool,
  zero : Bool,
) -> Unit {
  let digits = u.to_string(radix~)
  let mut body = apply_precision(
    if upper {
      digits.to_upper()
    } else {
      digits
    },
    prec,
  )
  let mut prefix = ""
  if alt && radix == 8 && !body.has_prefix("0") {
    body = "0" + body
  }
  if alt && radix == 16 && u != 0 {
    prefix = if upper { "0X" } else { "0x" }
  }
  let zero_eff = zero && !minus && prec is None
  push_string_utf8(ctx.out, pad_field(prefix, body, width, minus, zero_eff))
}

///|
fn emit_float(
  ctx : Ctx,
  conv : Char,
  x : Double,
  width : Int?,
  prec : Int?,
  minus : Bool,
  plus : Bool,
  space : Bool,
  zero : Bool,
  alt : Bool,
) -> Unit {
  let upper = conv is ('E' | 'G')
  if x.is_nan() || x.is_inf() {
    let mut body = if x.is_nan() {
      "nan"
    } else if x < 0.0 {
      "-inf"
    } else {
      "inf"
    }
    if upper {
      body = body.to_upper()
    }
    push_string_utf8(ctx.out, pad_text(body, width, minus))
    return
  }
  let p = prec.unwrap_or(6)
  let dec = dec_of(x)
  let body = match conv {
    'f' | 'F' => fmt_f(dec, p, alt)
    'e' | 'E' => fmt_e(dec, p, alt, upper)
    _ => fmt_g(dec, p, alt, upper)
  }
  let sign = if dec.neg {
    "-"
  } else if plus {
    "+"
  } else if space {
    " "
  } else {
    ""
  }
  push_string_utf8(ctx.out, pad_field(sign, body, width, minus, zero && !minus))
}

///|
fn emit_b(
  ctx : Ctx,
  text : String,
  width : Int?,
  prec : Int?,
  minus : Bool,
) -> Unit {
  let chars : Array[Char] = text.iter().collect()
  let bytes : Array[Byte] = []
  let mut i = 0
  let mut stopped = false
  while i < chars.length() {
    if chars[i] == '\\' {
      let (esc, used) = decode_escape(chars, i, in_b=true)
      match esc {
        Out(chunk) => bytes.append(chunk)
        Stop => {
          stopped = true
          break
        }
      }
      i += used
    } else {
      push_char_utf8(bytes, chars[i])
      i += 1
    }
  }
  let limited = match prec {
    Some(p) => if bytes.length() > p { bytes[0:p].to_owned() } else { bytes }
    None => bytes
  }
  let pad = match width {
    Some(w) => if w > limited.length() { w - limited.length() } else { 0 }
    None => 0
  }
  if pad > 0 && !minus {
    for _ in 0..<pad {
      ctx.out.push(b' ')
    }
  }
  ctx.out.append(limited)
  if pad > 0 && minus {
    for _ in 0..<pad {
      ctx.out.push(b' ')
    }
  }
  if stopped {
    ctx.stop = true
  }
}

///|
fn truncate_chars(s : String, limit : Int) -> String {
  let sb = StringBuilder()
  let mut n = 0
  for c in s {
    if n >= limit {
      break
    }
    sb.write_char(c)
    n += 1
  }
  sb.to_string()
}

///|
/// One pass over the format string; conversions consume arguments from ctx.
fn scan_format(ctx : Ctx, chars : Array[Char]) -> Unit {
  let mut i = 0
  while i < chars.length() {
    if ctx.stop || !(ctx.fatal is None) {
      return
    }
    let c = chars[i]
    if c == '\\' {
      let (esc, used) = decode_escape(chars, i)
      match esc {
        Out(bytes) => ctx.out.append(bytes)
        Stop => {
          ctx.stop = true
          return
        }
      }
      i += used
      continue
    }
    if c != '%' {
      push_char_utf8(ctx.out, c)
      i += 1
      continue
    }
    let mut j = i + 1
    let mut minus = false
    let mut plus = false
    let mut space = false
    let mut zero = false
    let mut alt = false
    while j < chars.length() {
      match chars[j] {
        '-' => minus = true
        '+' => plus = true
        ' ' => space = true
        '0' => zero = true
        '#' => alt = true
        _ => break
      }
      j += 1
    }
    let mut width : Int? = None
    if j < chars.length() && chars[j] == '*' {
      let arg = ctx.next_arg().unwrap_or("")
      let mut w = parse_int_arg(ctx, arg).to_int()
      if w < 0 {
        minus = true
        w = -w
      }
      width = Some(w)
      j += 1
    } else {
      let mut w = 0
      let mut any = false
      while j < chars.length() && chars[j] is ('0'..='9') {
        w = w * 10 + (chars[j].to_int() - 0x30)
        any = true
        j += 1
      }
      if any {
        width = Some(w)
      }
    }
    let mut prec : Int? = None
    if j < chars.length() && chars[j] == '.' {
      j += 1
      if j < chars.length() && chars[j] == '*' {
        let arg = ctx.next_arg().unwrap_or("")
        let p = parse_int_arg(ctx, arg).to_int()
        prec = if p < 0 { None } else { Some(p) }
        j += 1
      } else {
        let mut p = 0
        while j < chars.length() && chars[j] is ('0'..='9') {
          p = p * 10 + (chars[j].to_int() - 0x30)
          j += 1
        }
        prec = Some(p)
      }
    }
    if j >= chars.length() {
      ctx.fatal = Some("printf: missing conversion specifier at end of format")
      return
    }
    let conv = chars[j]
    i = j + 1
    match conv {
      '%' => ctx.out.push(b'%')
      'd' | 'i' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_signed(
          ctx,
          parse_int_arg(ctx, arg),
          width,
          prec,
          minus,
          plus,
          space,
          zero,
        )
      }
      'u' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_unsigned(
          ctx,
          parse_int_arg(ctx, arg).reinterpret_as_uint64(),
          10,
          false,
          false,
          width,
          prec,
          minus,
          zero,
        )
      }
      'o' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_unsigned(
          ctx,
          parse_int_arg(ctx, arg).reinterpret_as_uint64(),
          8,
          false,
          alt,
          width,
          prec,
          minus,
          zero,
        )
      }
      'x' | 'X' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_unsigned(
          ctx,
          parse_int_arg(ctx, arg).reinterpret_as_uint64(),
          16,
          conv == 'X',
          alt,
          width,
          prec,
          minus,
          zero,
        )
      }
      's' => {
        let arg = ctx.next_arg().unwrap_or("")
        let value = match prec {
          Some(p) => truncate_chars(arg, p)
          None => arg
        }
        push_string_utf8(ctx.out, pad_text(value, width, minus))
      }
      'c' => {
        let arg = ctx.next_arg().unwrap_or("")
        let value = match arg.get_char(0) {
          Some(ch) => ch.to_string()
          None => ""
        }
        push_string_utf8(ctx.out, pad_text(value, width, minus))
      }
      'b' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_b(ctx, arg, width, prec, minus)
      }
      'f' | 'F' | 'e' | 'E' | 'g' | 'G' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_float(
          ctx,
          conv,
          parse_double_arg(ctx, arg),
          width,
          prec,
          minus,
          plus,
          space,
          zero,
          alt,
        )
      }
      _ => {
        ctx.fatal = Some("printf: %\{conv}: invalid conversion specification")
        return
      }
    }
  }
}

///|
async fn main {
  let argv = @env.args()[1:]
  if argv.length() > 0 && argv[0] == "--help" {
    @stdio.stdout.write(help_message() + "\n")
    return
  }
  let operands = if argv.length() > 0 && argv[0] == "--" {
    argv[1:]
  } else {
    argv
  }
  if operands.is_empty() {
    @stdio.stderr.write(
      "printf: missing operand\nTry 'printf --help' for more information.\n",
    )
    @sys.exit(1)
    return
  }
  let format = operands[0]
  let ctx : Ctx = {
    out: [],
    args: operands[1:].to_owned(),
    arg_index: 0,
    warnings: [],
    stop: false,
    fatal: None,
  }
  let fmt_chars : Array[Char] = format.iter().collect()
  for ;; {
    let before = ctx.arg_index
    scan_format(ctx, fmt_chars)
    if ctx.stop || !(ctx.fatal is None) {
      break
    }
    if ctx.arg_index >= ctx.args.length() || ctx.arg_index == before {
      break
    }
  }
  @stdio.stdout.write(Bytes::from_array(ctx.out))
  for msg in ctx.warnings {
    @stdio.stderr.write(msg + "\n")
  }
  match ctx.fatal {
    Some(msg) => {
      @stdio.stderr.write(msg + "\n")
      @sys.exit(1)
      return
    }
    None => ()
  }
  if ctx.warnings.length() > 0 {
    @sys.exit(1)
  }
}
