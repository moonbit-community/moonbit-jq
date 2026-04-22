///|
/// Parse pipe expression (lowest precedence)
fn Parser::parse_pipe(self : Parser) -> @ast.Expr raise ParseError {
  let expr = self.parse_comma()
  if self.consume(TAs) {
    guard self.current() is Some(TVariable(var_name)) else {
      raise InvalidSyntax("Expected variable after 'as'")
    }
    self.advance()
    self.expect(TPipe)
    let body = self.parse_pipe()
    return @ast.Expr::As(expr, var_name, body)
  }
  let mut current = expr
  while self.consume(TPipe) {
    let right = self.parse_comma()
    current = @ast.Expr::Pipe(current, right)
  }
  current
}

///|
/// Parse comma expression
fn Parser::parse_comma(self : Parser) -> @ast.Expr raise ParseError {
  let mut current = self.parse_assignment()
  while self.consume(TComma) {
    let right = self.parse_assignment()
    current = @ast.Expr::Comma(current, right)
  }
  current
}
