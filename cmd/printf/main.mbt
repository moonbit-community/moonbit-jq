///|
priv struct Ctx {
  out : Array[Byte]
  args : Array[String]
  mut arg_index : Int
  messages : Array[String]
  mut exit_error : Bool
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
/// Record a diagnostic that also makes the final exit status 1.
fn Ctx::warn(self : Ctx, msg : String) -> Unit {
  self.messages.push(msg)
  self.exit_error = true
}

///|
/// Record a diagnostic that leaves the exit status unchanged.
fn Ctx::notice(self : Ctx, msg : String) -> Unit {
  self.messages.push(msg)
}

///|
fn is_blank(c : Char) -> Bool {
  c.to_int() is (0x20 | 0x09 | 0x0A | 0x0D | 0x0B | 0x0C)
}

///|
let uint64_max : UInt64 = 0xFFFF_FFFF_FFFF_FFFF

///|
let int64_max_mag : UInt64 = 0x7FFF_FFFF_FFFF_FFFF

///|
let int64_min_mag : UInt64 = 0x8000_0000_0000_0000

///|
/// Parse a printf integer argument like strtoimax/strtoumax: leading blanks,
/// 'C or "C for a character code, then the longest valid decimal, 0x hex, or
/// leading-0 octal prefix. Trailing text warns; overflow clamps and warns.
/// Returns the value's 64-bit pattern.
fn parse_integer(ctx : Ctx, text : String, unsigned~ : Bool) -> Int64 {
  let chars : Array[Char] = text.iter().collect()
  let mut i = 0
  while i < chars.length() && is_blank(chars[i]) {
    i += 1
  }
  if i >= chars.length() {
    ctx.warn("printf: '\{text}': expected a numeric value")
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
  let mut base = 10
  let mut digits_start = i
  if i < chars.length() &&
    chars[i] == '0' &&
    i + 1 < chars.length() &&
    (chars[i + 1] == 'x' || chars[i + 1] == 'X') &&
    i + 2 < chars.length() &&
    hex_val(chars[i + 2]) >= 0 {
    base = 16
    digits_start = i + 2
  } else if i < chars.length() && chars[i] == '0' {
    base = 8
  }
  let mut j = digits_start
  let mut any = false
  let mut mag : UInt64 = 0
  let mut overflow = false
  while j < chars.length() {
    let d = match base {
      16 => hex_val(chars[j])
      8 => if chars[j] is ('0'..='7') { chars[j].to_int() - 0x30 } else { -1 }
      _ => if chars[j] is ('0'..='9') { chars[j].to_int() - 0x30 } else { -1 }
    }
    if d < 0 {
      break
    }
    any = true
    let big_base = base.to_int64().reinterpret_as_uint64()
    let big_d = d.to_int64().reinterpret_as_uint64()
    if mag > (uint64_max - big_d) / big_base {
      overflow = true
    } else {
      mag = mag * big_base + big_d
    }
    j += 1
  }
  if !any {
    ctx.warn("printf: '\{text}': expected a numeric value")
    return 0
  }
  if j < chars.length() {
    ctx.warn("printf: '\{text}': value not completely converted")
  }
  if unsigned {
    if overflow {
      ctx.warn("printf: '\{text}': Result too large")
      return uint64_max.reinterpret_as_int64()
    }
    let bits = mag.reinterpret_as_int64()
    return if neg { -bits } else { bits }
  }
  if !neg && (overflow || mag > int64_max_mag) {
    ctx.warn("printf: '\{text}': Result too large")
    return int64_max_mag.reinterpret_as_int64()
  }
  if neg && (overflow || mag > int64_min_mag) {
    ctx.warn("printf: '\{text}': Result too large")
    return int64_min_mag.reinterpret_as_int64()
  }
  let bits = mag.reinterpret_as_int64()
  if neg {
    -bits
  } else {
    bits
  }
}

///|
fn matches_word(chars : Array[Char], start : Int, word : String) -> Bool {
  let want : Array[Char] = word.iter().collect()
  if start + want.length() > chars.length() {
    return false
  }
  for k, w in want {
    let c = chars[start + k]
    let lower = if c is ('A'..='Z') {
      (c.to_int() + 0x20).unsafe_to_char()
    } else {
      c
    }
    if lower != w {
      return false
    }
  }
  true
}

///|
fn pow2(exp : Int) -> Double {
  let mut result = 1.0
  if exp >= 0 {
    for _ in 0..<exp {
      result *= 2.0
    }
  } else {
    for _ in 0..<-exp {
      result /= 2.0
    }
  }
  result
}

///|
/// Parse a printf float argument like strtod: leading blanks, 'C, inf/nan,
/// hex floats (0x1.8p+2), or the longest valid decimal prefix. Trailing text
/// warns like GNU printf.
fn parse_double_arg(ctx : Ctx, text : String) -> Double {
  let chars : Array[Char] = text.iter().collect()
  let mut i = 0
  while i < chars.length() && is_blank(chars[i]) {
    i += 1
  }
  if i >= chars.length() {
    ctx.warn("printf: '\{text}': expected a numeric value")
    return 0.0
  }
  if chars[i] == '\'' || chars[i] == '"' {
    return if i + 1 < chars.length() {
      chars[i + 1].to_int().to_double()
    } else {
      0.0
    }
  }
  let mut neg = false
  if chars[i] == '+' || chars[i] == '-' {
    neg = chars[i] == '-'
    i += 1
  }
  let mut value = 0.0
  let mut end = i
  if matches_word(chars, i, "infinity") {
    value = 1.0 / 0.0
    end = i + 8
  } else if matches_word(chars, i, "inf") {
    value = 1.0 / 0.0
    end = i + 3
  } else if matches_word(chars, i, "nan") {
    value = 0.0 / 0.0
    end = i + 3
  } else if i + 1 < chars.length() &&
    chars[i] == '0' &&
    (chars[i + 1] == 'x' || chars[i + 1] == 'X') &&
    i + 2 < chars.length() &&
    (hex_val(chars[i + 2]) >= 0 || chars[i + 2] == '.') {
    // Hexadecimal float: 0xH[.H][p[+-]D]
    let mut j = i + 2
    let mut m = 0.0
    let mut any = false
    while j < chars.length() && hex_val(chars[j]) >= 0 {
      m = m * 16.0 + hex_val(chars[j]).to_double()
      any = true
      j += 1
    }
    if j < chars.length() && chars[j] == '.' {
      j += 1
      let mut scale = 1.0 / 16.0
      while j < chars.length() && hex_val(chars[j]) >= 0 {
        m += hex_val(chars[j]).to_double() * scale
        scale /= 16.0
        any = true
        j += 1
      }
    }
    if !any {
      // "0x" with no digits parses as 0 with trailing garbage.
      value = 0.0
      end = i + 1
    } else {
      if j < chars.length() && (chars[j] == 'p' || chars[j] == 'P') {
        let mut k = j + 1
        let mut esign = 1
        if k < chars.length() && (chars[k] == '+' || chars[k] == '-') {
          if chars[k] == '-' {
            esign = -1
          }
          k += 1
        }
        let mut ev = 0
        let mut edigits = false
        while k < chars.length() && chars[k] is ('0'..='9') {
          ev = ev * 10 + (chars[k].to_int() - 0x30)
          edigits = true
          k += 1
        }
        if edigits {
          m *= pow2(esign * ev)
          j = k
        }
      }
      value = m
      end = j
    }
  } else {
    // Decimal float: D[.D][e[+-]D]
    let mut j = i
    let mut any = false
    while j < chars.length() && chars[j] is ('0'..='9') {
      any = true
      j += 1
    }
    if j < chars.length() && chars[j] == '.' {
      j += 1
      while j < chars.length() && chars[j] is ('0'..='9') {
        any = true
        j += 1
      }
    }
    if !any {
      ctx.warn("printf: '\{text}': expected a numeric value")
      return 0.0
    }
    if j < chars.length() && (chars[j] == 'e' || chars[j] == 'E') {
      let mut k = j + 1
      if k < chars.length() && (chars[k] == '+' || chars[k] == '-') {
        k += 1
      }
      let mut edigits = false
      while k < chars.length() && chars[k] is ('0'..='9') {
        edigits = true
        k += 1
      }
      if edigits {
        j = k
      }
    }
    let sb = StringBuilder()
    sb.write_char('0')
    for k in i..<j {
      sb.write_char(chars[k])
    }
    value = @string.parse_double(sb.to_string()) catch { _ => 0.0 }
    end = j
  }
  if end < chars.length() {
    ctx.warn("printf: '\{text}': value not completely converted")
  }
  if neg {
    -value
  } else {
    value
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
  let upper = conv is ('E' | 'F' | 'G')
  let bits_neg = x.reinterpret_as_uint64() >> 63 != 0
  if x.is_nan() || x.is_inf() {
    let mut body = if x.is_nan() { "nan" } else { "inf" }
    if upper {
      body = body.to_upper()
    }
    let sign = if bits_neg {
      "-"
    } else if plus {
      "+"
    } else if space {
      " "
    } else {
      ""
    }
    // The zero flag pads non-finite values with spaces, like C printf.
    push_string_utf8(ctx.out, pad_field(sign, body, width, minus, false))
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
fn emit_b(ctx : Ctx, text : String) -> Unit {
  let chars : Array[Char] = text.iter().collect()
  let mut i = 0
  while i < chars.length() {
    if chars[i] == '\\' {
      let (esc, used) = decode_escape(chars, i, in_b=true)
      match esc {
        Out(chunk) => ctx.out.append(chunk)
        Stop => {
          ctx.stop = true
          return
        }
        Invalid(msg) => {
          ctx.fatal = Some(msg)
          return
        }
      }
      i += used
    } else {
      push_char_utf8(ctx.out, chars[i])
      i += 1
    }
  }
}

///|
/// GNU printf's per-conversion modifier rules, derived empirically:
/// %b and %% take no modifiers; # is limited to o/x/X and floats; the zero
/// flag is invalid for s/c; %c takes no precision.
fn spec_valid(
  conv : Char,
  minus : Bool,
  plus : Bool,
  space : Bool,
  zero : Bool,
  alt : Bool,
  width : Int?,
  prec : Int?,
) -> Bool {
  match conv {
    'd' | 'i' | 'u' => !alt
    'o' | 'x' | 'X' | 'e' | 'E' | 'f' | 'F' | 'g' | 'G' => true
    's' => !zero && !alt
    'c' => !zero && !alt && prec is None
    'b' | '%' =>
      !minus &&
      !plus &&
      !space &&
      !zero &&
      !alt &&
      width is None &&
      prec is None
    _ => true
  }
}

///|
let max_field : Int = 0x7FFFFFFF

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
        Invalid(msg) => {
          ctx.fatal = Some(msg)
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
    let spec_start = i
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
      let v = parse_integer(ctx, arg, unsigned=false)
      if v > max_field.to_int64() || v < -max_field.to_int64() {
        ctx.fatal = Some("printf: invalid field width: '\{arg}'")
        return
      }
      let mut w = v.to_int()
      if w < 0 {
        minus = true
        w = -w
      }
      width = Some(w)
      j += 1
    } else {
      let mut w = 0
      let mut any = false
      let digits_start = j
      while j < chars.length() && chars[j] is ('0'..='9') {
        if w > (max_field - 9) / 10 {
          let sb = StringBuilder()
          for k in digits_start..<chars.length() {
            if !(chars[k] is ('0'..='9')) {
              break
            }
            sb.write_char(chars[k])
          }
          ctx.fatal = Some("printf: invalid field width: '\{sb}'")
          return
        }
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
        let v = parse_integer(ctx, arg, unsigned=false)
        if v > max_field.to_int64() || v < -max_field.to_int64() {
          ctx.fatal = Some("printf: invalid precision: '\{arg}'")
          return
        }
        let p = v.to_int()
        prec = if p < 0 { None } else { Some(p) }
        j += 1
      } else {
        let mut p = 0
        let digits_start = j
        while j < chars.length() && chars[j] is ('0'..='9') {
          if p > (max_field - 9) / 10 {
            let sb = StringBuilder()
            for k in digits_start..<chars.length() {
              if !(chars[k] is ('0'..='9')) {
                break
              }
              sb.write_char(chars[k])
            }
            ctx.fatal = Some("printf: invalid precision: '\{sb}'")
            return
          }
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
    if !spec_valid(conv, minus, plus, space, zero, alt, width, prec) {
      let sb = StringBuilder()
      for k in spec_start..<i {
        sb.write_char(chars[k])
      }
      ctx.fatal = Some("printf: \{sb}: invalid conversion specification")
      return
    }
    match conv {
      '%' => ctx.out.push(b'%')
      'd' | 'i' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_signed(
          ctx,
          parse_integer(ctx, arg, unsigned=false),
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
          parse_integer(ctx, arg, unsigned=true).reinterpret_as_uint64(),
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
          parse_integer(ctx, arg, unsigned=true).reinterpret_as_uint64(),
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
          parse_integer(ctx, arg, unsigned=true).reinterpret_as_uint64(),
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
        // GNU printf measures %s width and precision in bytes.
        let arg = ctx.next_arg().unwrap_or("")
        let bytes : Array[Byte] = []
        push_string_utf8(bytes, arg)
        let limited = match prec {
          Some(p) =>
            if bytes.length() > p {
              bytes[0:p].to_owned()
            } else {
              bytes
            }
          None => bytes
        }
        emit_padded_bytes(ctx.out, limited, width, minus)
      }
      'c' => {
        // GNU printf emits only the first byte of the argument.
        let arg = ctx.next_arg().unwrap_or("")
        let bytes : Array[Byte] = []
        push_string_utf8(bytes, arg)
        let first = if bytes.length() > 0 { [bytes[0]] } else { [] }
        emit_padded_bytes(ctx.out, first, width, minus)
      }
      'b' => {
        let arg = ctx.next_arg().unwrap_or("")
        emit_b(ctx, arg)
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
    messages: [],
    exit_error: false,
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
    if ctx.arg_index >= ctx.args.length() {
      break
    }
    if ctx.arg_index == before {
      ctx.notice(
        "printf: warning: ignoring excess arguments, starting with '\{ctx.args[ctx.arg_index]}'",
      )
      break
    }
  }
  @stdio.stdout.write(Bytes::from_array(ctx.out))
  for msg in ctx.messages {
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
  if ctx.exit_error {
    @sys.exit(1)
  }
}
