///|
/// Lex a number
fn Lexer::lex_number(self : Lexer) -> Unit raise LexError {
  let start = self.pos
  let mut has_dot = false
  if self.current() == Some('-') {
    self.advance()
  }
  while true {
    match self.current() {
      Some(c) if is_digit(c) => self.advance()
      Some('.') if not(has_dot) && self.peek().map(is_digit).unwrap_or(false) => {
        has_dot = true
        self.advance()
      }
      _ => break
    }
  }
  let text = self.input[start:self.pos].to_string() catch {
    _ => raise InvalidNumber(start, "invalid slice")
  }
  let n = @strconv.parse_double(text) catch {
    _ => raise InvalidNumber(start, text)
  }
  self.add_token(TNumber(n))
}
