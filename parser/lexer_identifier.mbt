///|
/// Lex an identifier or keyword
fn Lexer::lex_identifier(self : Lexer) -> Unit {
  let start = self.pos
  while self.current().map(is_alnum).unwrap_or(false) {
    self.advance()
  }
  let text = try! self.input[start:self.pos].to_string()
  match text {
    "true" => self.add_token(TTrue)
    "false" => self.add_token(TFalse)
    "null" => self.add_token(TNull)
    "and" => self.add_token(TAnd)
    "or" => self.add_token(TOr)
    "not" => self.add_token(TNot)
    "if" => self.add_token(TIf)
    "then" => self.add_token(TThen)
    "else" => self.add_token(TElse)
    "elif" => self.add_token(TElif)
    "end" => self.add_token(TEnd)
    "as" => self.add_token(TAs)
    "reduce" => self.add_token(TReduce)
    "foreach" => self.add_token(TForeach)
    "try" => self.add_token(TTry)
    "catch" => self.add_token(TCatch)
    "def" => self.add_token(TDef)
    _ => self.add_token(TIdentifier(text))
  }
}

///|
/// Lex a variable ($name)
fn Lexer::lex_variable(self : Lexer) -> Unit {
  self.advance() // skip $
  let start = self.pos
  while self.current().map(is_alnum).unwrap_or(false) {
    self.advance()
  }
  let name = try! self.input[start:self.pos].to_string()
  self.add_token(TVariable(name))
}

///|
/// Lex a format (@name)
fn Lexer::lex_format(self : Lexer) -> Unit {
  self.advance() // skip @
  let start = self.pos
  while self.current().map(is_alnum).unwrap_or(false) {
    self.advance()
  }
  let name = try! self.input[start:self.pos].to_string()
  self.add_token(TFormat(name))
}
