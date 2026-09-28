///|
/// Lex a string (with interpolation support)
fn Lexer::lex_string(self : Lexer) -> Unit raise LexError {
  let start = self.pos
  self.advance()
  let parts : Array[(String, String?)] = []
  let buf = StringBuilder()
  while true {
    match self.current() {
      None => raise UnterminatedString(start)
      Some('"') => {
        self.advance()
        break
      }
      Some('\\') => {
        self.advance()
        match self.current() {
          None => raise UnterminatedString(start)
          Some('(') => {
            // String interpolation: \\(expr)
            self.advance()
            parts.push((buf.to_string(), None))
            buf.reset()
            // Find the matching closing paren
            let expr_start = self.pos
            let mut paren_depth = 1
            while true {
              match self.current() {
                None => raise UnterminatedString(start)
                Some('(') => {
                  self.advance()
                  paren_depth += 1
                  continue
                }
                Some(')') => {
                  paren_depth -= 1
                  if paren_depth == 0 {
                    let expr_text = self.input[expr_start:self.pos].to_owned()
                    parts.push(("", Some(expr_text)))
                    self.advance()
                    break
                  } else {
                    self.advance()
                    continue
                  }
                }
                Some('"') => {
                  // Skip nested strings
                  self.advance()
                  while true {
                    match self.current() {
                      Some('"') => {
                        self.advance()
                        break
                      }
                      Some('\\') => {
                        self.advance()
                        self.advance()
                        continue
                      }
                      None => raise UnterminatedString(start)
                      _ => {
                        self.advance()
                        continue
                      }
                    }
                  }
                  continue
                }
                _ => {
                  self.advance()
                  continue
                }
              }
            }
            continue
          }
          Some('n') => {
            buf.write_char('\n')
            self.advance()
            continue
          }
          Some('r') => {
            buf.write_char('\r')
            self.advance()
            continue
          }
          Some('t') => {
            buf.write_char('\t')
            self.advance()
            continue
          }
          Some('\\') => {
            buf.write_char('\\')
            self.advance()
            continue
          }
          Some('"') => {
            buf.write_char('"')
            self.advance()
            continue
          }
          Some('/') => {
            buf.write_char('/')
            self.advance()
            continue
          }
          Some('b') => {
            buf.write_char('\b')
            self.advance()
            continue
          }
          Some('f') => {
            buf.write_char('\u{0C}')
            self.advance()
            continue
          }
          Some('u') => {
            self.advance()
            self.lex_unicode_escape(buf)
            continue
          }
          Some(c) => raise InvalidEscape(self.pos, c)
        }
      }
      Some(c) => {
        buf.write_char(c)
        self.advance()
        continue
      }
    }
  }
  parts.push((buf.to_string(), None))
  match parts {
    [(s, None)] => self.add_token(TString(s))
    _ => self.add_token(TStringInterpolation(parts))
  }
}

///|
/// Read exactly four hex digits of a `\uXXXX` escape.
fn Lexer::lex_hex4(self : Lexer) -> Int raise LexError {
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
