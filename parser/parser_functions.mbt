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
    while true {
      match self.current() {
        Some(TIdentifier(p)) => {
          self.advance()
          params.push(p)
        }
        Some(TVariable(p)) => {
          self.advance()
          params.push("$" + p)
        }
        _ => raise InvalidSyntax("Expected function parameter")
      }
      if !self.consume(TSemicolon) {
        break
      }
    }
    self.expect(TRParen)
  }
  self.expect(TColon)
  let body = self.parse_definitions()
  self.expect(TSemicolon)
  FunctionDef(name, params, body)
}
