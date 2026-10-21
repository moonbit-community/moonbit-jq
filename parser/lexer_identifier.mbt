///|
/// Lex an identifier or keyword
fn Lexer::lex_identifier(self : Lexer) -> Unit {
  let start = self.pos
  while self.current().map(is_alnum).unwrap_or(false) {
    self.advance()
  }
  let text = self.input[start:self.pos].to_owned()
  let token = keywords
    .iter()
    .find_first(pair => pair.0 == text)
    .map(pair => pair.1)
    .unwrap_or(TIdentifier(text))
  self.add_token(token)
}

///|
/// Lex a variable ($name)
fn Lexer::lex_variable(self : Lexer) -> Unit raise LexError {
  let marker = self.pos
  self.advance() // skip $
  guard self.current().map(is_alpha).unwrap_or(false) else {
    raise UnexpectedChar(marker, '$')
  }
  let start = self.pos
  while self.current().map(is_alnum).unwrap_or(false) {
    self.advance()
  }
  let name = self.input[start:self.pos].to_owned()
  self.add_token(TVariable(name))
}

///|
/// Lex a format (@name)
fn Lexer::lex_format(self : Lexer) -> Unit raise LexError {
  let marker = self.pos
  self.advance() // skip @
  guard self.current().map(is_alnum).unwrap_or(false) else {
    raise UnexpectedChar(marker, '@')
  }
  let start = self.pos
  while self.current().map(is_alnum).unwrap_or(false) {
    self.advance()
  }
  let name = self.input[start:self.pos].to_owned()
  self.add_token(TFormat(name))
}

///|
/// The same spelling table is used for names in object keys.
fn Token::name(self : Token) -> String? {
  match self {
    TIdentifier(name) => Some(name)
    _ => keywords.iter().find_first(pair => pair.1 == self).map(pair => pair.0)
  }
}

///|
/// One spelling table for code keywords and unquoted object names.
let keywords : Array[(String, Token)] = [
  ("true", TTrue),
  ("false", TFalse),
  ("null", TNull),
  ("and", TAnd),
  ("or", TOr),
  ("if", TIf),
  ("then", TThen),
  ("else", TElse),
  ("elif", TElif),
  ("end", TEnd),
  ("as", TAs),
  ("reduce", TReduce),
  ("foreach", TForeach),
  ("try", TTry),
  ("catch", TCatch),
  ("def", TDef),
]
