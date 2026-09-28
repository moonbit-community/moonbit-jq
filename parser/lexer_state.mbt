///|
/// Lexer state
priv struct Lexer {
  input : String
  mut pos : Int
  tokens : Array[Token]
}

///|
/// Create a new lexer
fn Lexer::new(input : String) -> Lexer {
  { input, pos: 0, tokens: [], }
}

///|
/// Get current character
fn Lexer::current(self : Lexer) -> Char? {
  if self.pos < self.input.length() {
    self.input.get_char(self.pos)
  } else {
    None
  }
}

///|
/// Peek at next character
fn Lexer::peek(self : Lexer) -> Char? {
  if self.pos + 1 < self.input.length() {
    self.input.get_char(self.pos + 1)
  } else {
    None
  }
}

///|
/// Advance past the current character. `pos` is a UTF-16 index, so a
/// character outside the BMP (a surrogate pair) advances by two.
fn Lexer::advance(self : Lexer) -> Unit {
  match self.current() {
    Some(c) if c.to_int() > 0xFFFF => self.pos += 2
    _ => self.pos += 1
  }
}

///|
/// Add a token
fn Lexer::add_token(self : Lexer, token : Token) -> Unit {
  self.tokens.push(token)
}

///|
/// Skip whitespace
fn Lexer::skip_whitespace(self : Lexer) -> Unit {
  while true {
    match self.current() {
      Some(' ') | Some('\n') | Some('\r') | Some('\t') => {
        self.advance()
        continue
      }
      _ => break
    }
  }
}

///|
/// Skip comment (# to end of line)
fn Lexer::skip_comment(self : Lexer) -> Unit {
  while true {
    match self.current() {
      Some('\n') | None => break
      _ => {
        self.advance()
        continue
      }
    }
  }
}
