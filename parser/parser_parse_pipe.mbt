///|
/// Parse pipe expression (lowest precedence)
fn Parser::parse_pipe_inner(self : Parser) -> @ast.Expr raise ParseError {
  let expr = self.parse_comma()
  if self.consume(TAs) {
    guard self.current() is Some(TVariable(var_name)) else {
      raise InvalidSyntax("Expected variable after 'as'")
    }
    self.advance()
    self.expect(TPipe)
    let body = self.parse_definitions()
    return As(expr, var_name, body)
  }
  if self.consume(TPipe) {
    Pipe(expr, self.parse_definitions())
  } else {
    expr
  }
}

///|
/// Parse comma expression
fn Parser::parse_comma_inner(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  let mut current = self.parse_assignment()
  while self.consume(TComma) {
    let right = self.parse_assignment()
    current = self.located(start, Comma(current, right))
  }
  current
}

///|
fn Parser::parse_pipe(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_pipe_inner())
}

///|
fn Parser::parse_comma(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_comma_inner())
}
