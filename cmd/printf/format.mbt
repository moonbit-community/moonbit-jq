///|
/// Result of decoding one backslash escape sequence.
priv enum EscOut {
  Out(Array[Byte])
  Stop
  Invalid(String)
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
fn push_char_utf8(out : Array[Byte], c : Char) -> Unit {
  if c.to_int() < 0x80 {
    out.push(c.to_int().to_byte())
  } else {
    for b in @utf8.encode(c.to_string()) {
      out.push(b)
    }
  }
}

///|
fn push_string_utf8(out : Array[Byte], s : String) -> Unit {
  for b in @utf8.encode(s) {
    out.push(b)
  }
}

///|
/// Decode the escape sequence whose backslash sits at `start`. Returns the
/// output and the number of characters consumed (including the backslash).
/// Octal accepts `\NNN` and `\0NNN`, hex `\xHH`, Unicode `\uHHHH`/`\UHHHHHHHH`,
/// and `\c` stops all output. Unknown escapes pass through literally.
fn decode_escape(
  chars : Array[Char],
  start : Int,
  in_b? : Bool = false,
) -> (EscOut, Int) {
  if start + 1 >= chars.length() {
    return (Out([b'\\']), 1)
  }
  let e = chars[start + 1]
  let simple : Int = match e {
    'a' => 0x07
    'b' => 0x08
    'e' => 0x1B
    'f' => 0x0C
    'n' => 0x0A
    'r' => 0x0D
    't' => 0x09
    'v' => 0x0B
    '\\' => 0x5C
    '"' => 0x22
    '\'' => 0x27
    _ => -1
  }
  if simple >= 0 {
    return (Out([simple.to_byte()]), 2)
  }
  if e == 'c' {
    return (Stop, 2)
  }
  if e is ('0'..='7') {
    // FORMAT strings take up to three octal digits total (`\101`, and `\010`
    // leaves a following digit alone). In %b arguments a leading `0` is a
    // marker followed by up to three more digits (`\0102` is one byte), while
    // `\101` still works, matching GNU printf.
    let mut i = start + 1
    if in_b && e == '0' {
      i += 1
    }
    let mut value = 0
    let mut count = 0
    while i < chars.length() && count < 3 && chars[i] is ('0'..='7') {
      value = value * 8 + (chars[i].to_int() - 0x30)
      i += 1
      count += 1
    }
    return (Out([(value % 256).to_byte()]), i - start)
  }
  if e == 'x' {
    let mut i = start + 2
    let mut value = 0
    let mut count = 0
    while i < chars.length() && count < 2 && hex_val(chars[i]) >= 0 {
      value = value * 16 + hex_val(chars[i])
      i += 1
      count += 1
    }
    if count == 0 {
      return (Invalid("printf: missing hexadecimal number in escape"), 2)
    }
    return (Out([value.to_byte()]), 2 + count)
  }
  if e == 'u' || e == 'U' {
    let need = if e == 'u' { 4 } else { 8 }
    let mut value = 0
    for k in 0..<need {
      let idx = start + 2 + k
      if idx >= chars.length() || hex_val(chars[idx]) < 0 {
        return (Invalid("printf: missing hexadecimal number in escape"), 2)
      }
      value = value * 16 + hex_val(chars[idx])
    }
    if value >= 0xD800 && value <= 0xDFFF {
      // Surrogates are rejected like GNU printf...
      return (
        Invalid("printf: invalid universal character name \\\{e}"),
        2 + need,
      )
    }
    match value.to_char() {
      Some(c) => {
        let out : Array[Byte] = []
        push_char_utf8(out, c)
        (Out(out), 2 + need)
      }
      None => {
        // ...while complete but out-of-range names pass through literally.
        let out : Array[Byte] = []
        out.push(b'\\')
        push_char_utf8(out, e)
        for k in 0..<need {
          push_char_utf8(out, chars[start + 2 + k])
        }
        (Out(out), 2 + need)
      }
    }
  } else {
    // Unknown escape: print backslash and the character literally.
    let out : Array[Byte] = []
    out.push(b'\\')
    push_char_utf8(out, e)
    (Out(out), 2)
  }
}

///|
fn repeat_char(c : Char, n : Int) -> String {
  let sb = StringBuilder()
  for _ in 0..<n {
    sb.write_char(c)
  }
  sb.to_string()
}

///|
/// Left-pad `body` with zeros to at least `prec` digits; precision 0 renders
/// the value 0 as an empty string, matching C printf.
fn apply_precision(body : String, prec : Int?) -> String {
  match prec {
    Some(p) => {
      if body == "0" && p == 0 {
        return ""
      }
      if body.length() >= p {
        body
      } else {
        repeat_char('0', p - body.length()) + body
      }
    }
    None => body
  }
}

///|
/// Assemble sign/prefix + body into a field of `width` characters. With the
/// zero flag, padding zeros go between the prefix and the body.
fn pad_field(
  prefix : String,
  body : String,
  width : Int?,
  minus : Bool,
  zero : Bool,
) -> String {
  let content = prefix + body
  match width {
    Some(w) =>
      if content.length() >= w {
        content
      } else if minus {
        content + repeat_char(' ', w - content.length())
      } else if zero {
        prefix + repeat_char('0', w - content.length()) + body
      } else {
        repeat_char(' ', w - content.length()) + content
      }
    None => content
  }
}

///|
/// Append raw bytes into `out`, space-padded to `width` bytes.
fn emit_padded_bytes(
  out : Array[Byte],
  bytes : Array[Byte],
  width : Int?,
  minus : Bool,
) -> Unit {
  let pad = match width {
    Some(w) => if w > bytes.length() { w - bytes.length() } else { 0 }
    None => 0
  }
  if pad > 0 && !minus {
    for _ in 0..<pad {
      out.push(b' ')
    }
  }
  out.append(bytes)
  if pad > 0 && minus {
    for _ in 0..<pad {
      out.push(b' ')
    }
  }
}

///|
/// A decimal representation of a finite double: value = 0.digits * 10^exp,
/// with no leading or trailing zero digits. An empty digit array means zero.
priv struct Dec {
  neg : Bool
  digs : Array[Int]
  exp : Int
}

///|
/// Build the exact decimal expansion of a finite double from its bits:
/// value = m * 2^e2, and 2^-k = 5^k / 10^k, so the digits of m * 5^k with the
/// decimal point k places from the right are exact.
fn dec_of(x : Double) -> Dec {
  let bits = x.reinterpret_as_uint64()
  let neg = bits >> 63 != 0
  let biased = ((bits >> 52) & 0x7FF).to_int()
  let frac = bits & 0x000F_FFFF_FFFF_FFFF
  let implicit_bit : UInt64 = 0x0010_0000_0000_0000
  let (m, e2) = if biased == 0 {
    (frac, -1074)
  } else {
    (frac | implicit_bit, biased - 1075)
  }
  if m == 0 {
    return { neg, digs: [], exp: 0 }
  }
  let big_m = BigInt::from_uint64(m)
  let (n, point) = if e2 >= 0 {
    (big_m * BigInt::from_int(2).pow(BigInt::from_int(e2)), 0)
  } else {
    (big_m * BigInt::from_int(5).pow(BigInt::from_int(-e2)), -e2)
  }
  let text = n.to_string()
  let digs : Array[Int] = []
  for c in text {
    digs.push(c.to_int() - 0x30)
  }
  let exp = digs.length() - point
  while digs.length() > 0 && digs[digs.length() - 1] == 0 {
    ignore(digs.pop())
  }
  { neg, digs, exp }
}

///|
/// True when dropping digits[k..] rounds the kept prefix upward, using
/// round-half-even on the exact expansion like C printf.
fn rounds_up(digs : Array[Int], k : Int) -> Bool {
  if k >= digs.length() {
    return false
  }
  let first = digs[k]
  if first > 5 {
    return true
  }
  if first < 5 {
    return false
  }
  for i in (k + 1)..<digs.length() {
    if digs[i] != 0 {
      return true
    }
  }
  // Exact tie: round to make the last kept digit even.
  k > 0 && digs[k - 1] % 2 == 1
}

///|
/// Round to at most k significant digits (half-even on the exact expansion).
fn dec_round_sig(d : Dec, k : Int) -> Dec {
  if d.digs.length() <= k {
    return d
  }
  let kept : Array[Int] = []
  for i in 0..<k {
    kept.push(d.digs[i])
  }
  let mut exp = d.exp
  if rounds_up(d.digs, k) {
    let mut idx = k - 1
    let mut carry = true
    while carry && idx >= 0 {
      if kept[idx] == 9 {
        kept[idx] = 0
        idx -= 1
      } else {
        kept[idx] += 1
        carry = false
      }
    }
    if carry {
      // 999... rounded up to 1000...: a single leading 1, one place higher.
      kept.clear()
      kept.push(1)
      exp += 1
    }
  }
  while kept.length() > 0 && kept[kept.length() - 1] == 0 {
    ignore(kept.pop())
  }
  if kept.is_empty() {
    { neg: d.neg, digs: [], exp: 0 }
  } else {
    { neg: d.neg, digs: kept, exp }
  }
}

///|
/// Fixed-point rendering of the magnitude with `p` fraction digits.
fn fmt_f(d : Dec, p : Int, alt : Bool) -> String {
  let d2 = if d.digs.is_empty() {
    d
  } else {
    let k = d.exp + p
    if k < 0 {
      { neg: d.neg, digs: [], exp: 0 }
    } else if k == 0 {
      // The value sits entirely below the rounding place; it rounds up to
      // one unit in the last place only past the halfway point (a tie
      // rounds toward the even 0).
      if rounds_up(d.digs, 0) {
        { neg: d.neg, digs: [1], exp: -p + 1 }
      } else {
        { neg: d.neg, digs: [], exp: 0 }
      }
    } else {
      dec_round_sig(d, k)
    }
  }
  let sb = StringBuilder()
  let int_count = if d2.exp > 0 { d2.exp } else { 0 }
  if int_count == 0 {
    sb.write_char('0')
  } else {
    for i in 0..<int_count {
      let digit = if i < d2.digs.length() { d2.digs[i] } else { 0 }
      sb.write_char((0x30 + digit).unsafe_to_char())
    }
  }
  if p > 0 || alt {
    sb.write_char('.')
  }
  for pos in 1..<=p {
    let i = d2.exp - 1 + pos
    let digit = if i >= 0 && i < d2.digs.length() { d2.digs[i] } else { 0 }
    sb.write_char((0x30 + digit).unsafe_to_char())
  }
  sb.to_string()
}

///|
/// Scientific rendering of the magnitude with `p` mantissa fraction digits.
fn fmt_e(d : Dec, p : Int, alt : Bool, upper : Bool) -> String {
  let sb = StringBuilder()
  if d.digs.is_empty() {
    sb.write_char('0')
    if p > 0 || alt {
      sb.write_char('.')
    }
    for _ in 0..<p {
      sb.write_char('0')
    }
    sb.write_string(if upper { "E+00" } else { "e+00" })
    return sb.to_string()
  }
  let d2 = dec_round_sig(d, p + 1)
  sb.write_char((0x30 + d2.digs[0]).unsafe_to_char())
  if p > 0 || alt {
    sb.write_char('.')
  }
  for j in 1..<=p {
    let digit = if j < d2.digs.length() { d2.digs[j] } else { 0 }
    sb.write_char((0x30 + digit).unsafe_to_char())
  }
  let e10 = d2.exp - 1
  sb.write_char(if upper { 'E' } else { 'e' })
  sb.write_char(if e10 < 0 { '-' } else { '+' })
  let mag = if e10 < 0 { -e10 } else { e10 }
  let etext = mag.to_string()
  if etext.length() < 2 {
    sb.write_char('0')
  }
  sb.write_string(etext)
  sb.to_string()
}

///|
/// Strip the trailing fraction zeros %g produces (and a bare trailing point).
fn strip_g(s : String) -> String {
  let chars : Array[Char] = s.iter().collect()
  let mut split = chars.length()
  for i in 0..<chars.length() {
    if chars[i] == 'e' || chars[i] == 'E' {
      split = i
      break
    }
  }
  let mut has_point = false
  for i in 0..<split {
    if chars[i] == '.' {
      has_point = true
      break
    }
  }
  if !has_point {
    return s
  }
  let mut end = split
  while end > 0 && chars[end - 1] == '0' {
    end -= 1
  }
  if end > 0 && chars[end - 1] == '.' {
    end -= 1
  }
  let sb = StringBuilder()
  for i in 0..<end {
    sb.write_char(chars[i])
  }
  for i in split..<chars.length() {
    sb.write_char(chars[i])
  }
  sb.to_string()
}

///|
/// General rendering of the magnitude with `p0` significant digits.
fn fmt_g(d : Dec, p0 : Int, alt : Bool, upper : Bool) -> String {
  let precision = if p0 == 0 { 1 } else { p0 }
  let d2 = dec_round_sig(d, precision)
  let x = if d2.digs.is_empty() { 0 } else { d2.exp - 1 }
  let s = if x < -4 || x >= precision {
    fmt_e(d2, precision - 1, alt, upper)
  } else {
    fmt_f(d2, precision - 1 - x, alt)
  }
  if alt {
    s
  } else {
    strip_g(s)
  }
}
