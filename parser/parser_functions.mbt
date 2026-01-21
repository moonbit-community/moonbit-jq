///|
/// Parse function definition: def name(params): body;
fn Parser::parse_function_def(self : Parser) -> @ast.Expr raise ParseError {
  self.expect(TDef)
  guard self.current() is Some(TIdentifier(name)) else {
    raise UnexpectedToken("identifier", "function name")
  }
  self.advance()
  let params : Array[String] = []
  // Optional parameters
  if self.consume(TLParen) {
    if self.current() is Some(TIdentifier(p)) {
      self.advance()
      params.push(p)
      while self.consume(TSemicolon) {
        guard self.current() is Some(TIdentifier(p2)) else {
          raise UnexpectedToken("identifier", "parameter")
        }
        self.advance()
        params.push(p2)
      }
    }
    self.expect(TRParen)
  }
  self.expect(TColon)
  let body = self.parse_pipe()
  self.expect(TSemicolon)
  @ast.Expr::FunctionDef(name, params, body)
}
