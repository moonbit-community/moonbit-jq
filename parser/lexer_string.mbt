///|
fn Lexer::lex_string(self : Lexer) -> Unit {
  let start = self.pos
  self.advance()
  self.add_token(TStringStart)
  self.modes.push(StringMode(start))
}

///|
fn Lexer::lex_string_text(self : Lexer, start : Int32) -> Unit raise LexError {
  let buf = StringBuilder()
  while true {
    match self.current() {
      None => raise UnterminatedString(start)
      Some('"') => {
        if !buf.is_empty() {
          self.add_token(TStringText(buf.to_string()))
        }
        self.start = self.pos
        self.advance()
        self.add_token(TStringEnd)
        self.modes.pop() |> ignore
        return
      }
      Some('\\') => {
        let escape_start = self.pos
        if self.peek() == Some('(') {
          if !buf.is_empty() {
            self.add_token(TStringText(buf.to_string()))
          }
          self.start = escape_start
          self.advance()
          self.advance()
          self.add_token(TInterpolationStart)
          self.modes.push(Code(TInterpolationEnd))
          return
        }
        self.advance()
        match self.current() {
          Some('n') => buf.write_char('\n')
          Some('r') => buf.write_char('\r')
          Some('t') => buf.write_char('\t')
          Some('b') => buf.write_char('\b')
          Some('f') => buf.write_char('\u{0C}')
          Some('\\') => buf.write_char('\\')
          Some('"') => buf.write_char('"')
          Some('/') => buf.write_char('/')
          Some('u') => {
            self.advance()
            self.lex_unicode_escape(buf)
            continue
          }
          Some(c) => raise InvalidEscape(self.pos, c)
          None => raise UnterminatedString(start)
        }
        self.advance()
      }
      Some(c) => {
        buf.write_char(c)
        self.advance()
      }
    }
  }
}

///|
/// Read exactly four hex digits of a `\uXXXX` escape.
fn Lexer::lex_hex4(self : Lexer) -> Int32 raise LexError {
  let mut value = 0
  for _ in 0..<4 {
    let digit = match self.current() {
      Some(c) if c >= '0' && c <= '9' => c.to_int() - '0'.to_int()
      Some(c) if c >= 'a' && c <= 'f' => c.to_int() - 'a'.to_int() + 10
      Some(c) if c >= 'A' && c <= 'F' => c.to_int() - 'A'.to_int() + 10
      Some(c) => raise InvalidEscape(self.pos, c)
      None => raise UnterminatedString(self.pos)
    }
    value = value * 16 + digit
    self.advance()
  }
  value
}

///|
/// Decode the rest of a `\uXXXX` escape (the `\u` is already consumed).
/// As in jq 1.7 (jv_parse.c), a high surrogate must be followed by a
/// `\uXXXX` low surrogate, otherwise the escape is invalid; a lone low
/// surrogate becomes U+FFFD.
fn Lexer::lex_unicode_escape(
  self : Lexer,
  buf : StringBuilder,
) -> Unit raise LexError {
  let start = self.pos
  let unit = self.lex_hex4()
  if unit >= 0xD800 && unit <= 0xDBFF {
    guard self.current() == Some('\\') && self.peek() == Some('u') else {
      raise InvalidEscape(start, 'u')
    }
    self.advance()
    self.advance()
    let low = self.lex_hex4()
    guard low >= 0xDC00 && low <= 0xDFFF else {
      raise InvalidEscape(start, 'u')
    }
    let code_point = 0x10000 + ((unit - 0xD800) << 10) + (low - 0xDC00)
    buf.write_char(code_point.unsafe_to_char())
  } else if unit >= 0xDC00 && unit <= 0xDFFF {
    buf.write_char('\u{FFFD}')
  } else {
    buf.write_char(unit.unsafe_to_char())
  }
}
