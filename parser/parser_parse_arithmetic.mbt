///|
/// Parse additive operators
fn Parser::parse_additive_inner(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  let mut expr = self.parse_multiplicative()
  while true {
    match self.current() {
      Some(TPlus) => {
        self.advance()
        expr = self.located(
          start,
          Operation(expr, Add, self.parse_multiplicative()),
        )
        continue
      }
      Some(TMinus) => {
        self.advance()
        expr = self.located(
          start,
          Operation(expr, Subtract, self.parse_multiplicative()),
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
fn Parser::parse_multiplicative_inner(
  self : Parser,
) -> @ast.Expr raise ParseError {
  let start = self.pos
  let mut expr = self.parse_unary()
  while true {
    match self.current() {
      Some(TStar) => {
        self.advance()
        expr = self.located(
          start,
          Operation(expr, Multiply, self.parse_unary()),
        )
        continue
      }
      Some(TSlash) => {
        self.advance()
        expr = self.located(start, Operation(expr, Divide, self.parse_unary()))
        continue
      }
      Some(TPercent) => {
        self.advance()
        expr = self.located(start, Operation(expr, Modulo, self.parse_unary()))
        continue
      }
      _ => break
    }
  }
  expr
}

///|
/// Parse unary operators
fn Parser::parse_unary_inner(self : Parser) -> @ast.Expr raise ParseError {
  if self.consume(TMinus) {
    let rhs = self.parse_unary()
    match rhs {
      Located(span, Literal(Number(n))) => Located(span, Literal(Number(-n)))
      _ => Operation(Literal(Number(0)), Subtract, rhs)
    }
  } else {
    self.parse_postfix()
  }
}

///|
fn Parser::parse_additive(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_additive_inner())
}

///|
fn Parser::parse_multiplicative(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_multiplicative_inner())
}

///|
fn Parser::parse_unary(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_unary_inner())
}
