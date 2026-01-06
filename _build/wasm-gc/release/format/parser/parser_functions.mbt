///|
/// Parse function definition: def name(params): body;
fn Parser::parse_function_def(self : Parser) -> @ast.Expr raise ParseError {
  self.expect(TDef)
  let name = match self.current() {
    Some(TIdentifier(n)) => {
      self.advance()
      n
    }
    _ => raise UnexpectedToken("identifier", "function name")
  }
  let params : Array[String] = []
  // Optional parameters
  if self.consume(TLParen) {
    if not(self.current() == Some(TRParen)) {
      match self.current() {
        Some(TIdentifier(p)) => {
          self.advance()
          params.push(p)
        }
        _ => raise UnexpectedToken("identifier", "parameter")
      }
      while self.consume(TSemicolon) {
        match self.current() {
          Some(TIdentifier(p)) => {
            self.advance()
            params.push(p)
          }
          _ => raise UnexpectedToken("identifier", "parameter")
        }
      }
    }
    self.expect(TRParen)
  }
  self.expect(TColon)
  let body = self.parse_pipe()
  self.expect(TSemicolon)
  @ast.Expr::FunctionDef(name, params, body)
}
