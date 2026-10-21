///|
/// Parse logical or
fn Parser::parse_or_inner(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  let mut expr = self.parse_and()
  while self.consume(TOr) {
    expr = self.located(start, Operation(expr, Or, self.parse_and()))
  }
  expr
}

///|
/// Parse logical and
fn Parser::parse_and_inner(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  let mut expr = self.parse_comparison()
  while self.consume(TAnd) {
    expr = self.located(start, Operation(expr, And, self.parse_comparison()))
  }
  expr
}

///|
/// Parse comparison operators
fn Parser::parse_comparison_inner(self : Parser) -> @ast.Expr raise ParseError {
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

///|
fn Parser::parse_or(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_or_inner())
}

///|
fn Parser::parse_and(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_and_inner())
}

///|
fn Parser::parse_comparison(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_comparison_inner())
}
