///|
/// Parse additive operators
fn Parser::parse_additive(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_multiplicative()
  while true {
    match self.current() {
      Some(TPlus) => {
        self.advance()
        expr = Operation(
          expr,
          Add,
          self.parse_multiplicative(),
        )
        continue
      }
      Some(TMinus) => {
        self.advance()
        expr = Operation(
          expr,
          Subtract,
          self.parse_multiplicative(),
        )
        continue
      }
      _ => break
    }
  }
  expr
}

///|
/// Parse multiplicative operators
fn Parser::parse_multiplicative(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_unary()
  while true {
    match self.current() {
      Some(TStar) => {
        self.advance()
        expr = Operation(
          expr,
          Multiply,
          self.parse_unary(),
        )
        continue
      }
      Some(TSlash) => {
        self.advance()
        expr = Operation(
          expr,
          Divide,
          self.parse_unary(),
        )
        continue
      }
      Some(TPercent) => {
        self.advance()
        expr = Operation(
          expr,
          Modulo,
          self.parse_unary(),
        )
        continue
      }
      _ => break
    }
  }
  expr
}

///|
/// Parse unary operators
fn Parser::parse_unary(self : Parser) -> @ast.Expr raise ParseError {
  if self.consume(TNot) {
    Not
  } else {
    self.parse_postfix()
  }
}
