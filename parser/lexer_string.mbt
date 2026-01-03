///|
/// Lex a string (with interpolation support)
fn Lexer::lex_string(self : Lexer) -> Unit raise LexError {
  let start = self.pos
  self.advance()
  let parts : Array[(String, String?)] = []
  let buf = @buffer.new()
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
            let _ = loop 1 {
              paren_depth =>
                match self.current() {
                  None => raise UnterminatedString(start)
                  Some('(') => {
                    self.advance()
                    continue paren_depth + 1
                  }
                  Some(')') => {
                    let next_depth = paren_depth - 1
                    if next_depth == 0 {
                      let expr_text = try! self.input[expr_start:self.pos].to_string()
                      parts.push(("", Some(expr_text)))
                      self.advance()
                      ()
                    } else {
                      self.advance()
                      continue next_depth
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
                        }
                        None => raise UnterminatedString(start)
                        _ => self.advance()
                      }
                    }
                    continue paren_depth
                  }
                  _ => {
                    self.advance()
                    continue paren_depth
                  }
                }
            }
          }
          Some('n') => {
            buf.write_char('\n')
            self.advance()
          }
          Some('r') => {
            buf.write_char('\r')
            self.advance()
          }
          Some('t') => {
            buf.write_char('\t')
            self.advance()
          }
          Some('\\') => {
            buf.write_char('\\')
            self.advance()
          }
          Some('"') => {
            buf.write_char('"')
            self.advance()
          }
          Some('/') => {
            buf.write_char('/')
            self.advance()
          }
          Some('b') => {
            buf.write_char('\b')
            self.advance()
          }
          Some(c) => raise InvalidEscape(self.pos, c)
        }
      }
      Some(c) => {
        buf.write_char(c)
        self.advance()
      }
    }
  }
  parts.push((buf.to_string(), None))
  if parts.length() == 1 && parts[0].1 == None {
    self.add_token(TString(parts[0].0))
  } else {
    self.add_token(TStringInterpolation(parts))
  }
}
