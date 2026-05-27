///|
/// Parse logical or
fn Parser::parse_or(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_and()
  while self.consume(TOr) {
    expr = Operation(expr, Or, self.parse_and())
  }
  expr
}

///|
/// Parse logical and
fn Parser::parse_and(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_comparison()
  while self.consume(TAnd) {
    expr = Operation(expr, And, self.parse_comparison())
  }
  expr
}

///|
/// Parse comparison operators
fn Parser::parse_comparison(self : Parser) -> @ast.Expr raise ParseError {
  let expr = self.parse_additive()
  match self.current() {
    Some(TEq) => {
      self.advance()
      Operation(expr, Equal, self.parse_additive())
    }
    Some(TNeq) => {
      self.advance()
      Operation(expr, NotEqual, self.parse_additive())
    }
    Some(TLt) => {
      self.advance()
      Operation(expr, LessThan, self.parse_additive())
    }
    Some(TLe) => {
      self.advance()
      Operation(expr, LessEq, self.parse_additive())
    }
    Some(TGt) => {
      self.advance()
      Operation(expr, GreaterThan, self.parse_additive())
    }
    Some(TGe) => {
      self.advance()
      Operation(expr, GreaterEq, self.parse_additive())
    }
    _ => expr
  }
}
