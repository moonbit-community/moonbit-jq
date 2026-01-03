///|
/// Parse pipe expression (lowest precedence)
fn Parser::parse_pipe(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_comma()

  // Check for 'as $var' binding
  if self.consume(TAs) {
    let var_name = match self.current() {
      Some(TVariable(name)) => {
        self.advance()
        name
      }
      _ => raise InvalidSyntax("Expected variable after 'as'")
    }
    // Expect pipe, then parse rest as body
    self.expect(TPipe)
    let body = self.parse_pipe() // Recursively parse rest of pipe with variable in scope
    return @ast.Expr::As(expr, var_name, body)
  }

  // Normal pipe processing
  while self.consume(TPipe) {
    let right = self.parse_comma()
    expr = @ast.Expr::Pipe(expr, right)
  }
  expr
}

///|
/// Parse comma expression
fn Parser::parse_comma(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_assignment()
  while self.consume(TComma) {
    let right = self.parse_assignment()
    expr = @ast.Expr::Comma(expr, right)
  }
  expr
}

///|
/// Parse assignment operators
fn Parser::parse_assignment(self : Parser) -> @ast.Expr raise ParseError {
  let expr = self.parse_or()
  match self.current() {
    Some(TAssign) => {
      self.advance()
      @ast.Expr::Assign(expr, self.parse_or())
    }
    Some(TUpdate) => {
      self.advance()
      @ast.Expr::Update(expr, self.parse_or())
    }
    Some(TAlternative) => {
      self.advance()
      @ast.Expr::Alternative(expr, self.parse_or())
    }
    Some(TAddAssign) => {
      self.advance()
      @ast.Expr::AddAssign(expr, self.parse_or())
    }
    Some(TSubAssign) => {
      self.advance()
      @ast.Expr::SubAssign(expr, self.parse_or())
    }
    Some(TMulAssign) => {
      self.advance()
      @ast.Expr::MulAssign(expr, self.parse_or())
    }
    Some(TDivAssign) => {
      self.advance()
      @ast.Expr::DivAssign(expr, self.parse_or())
    }
    Some(TModAssign) => {
      self.advance()
      @ast.Expr::ModAssign(expr, self.parse_or())
    }
    Some(TAltAssign) => {
      self.advance()
      @ast.Expr::AltAssign(expr, self.parse_or())
    }
    _ => expr
  }
}

///|
/// Parse logical or
fn Parser::parse_or(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_and()
  while self.consume(TOr) {
    expr = @ast.Expr::Operation(expr, @ast.BinaryOp::Or, self.parse_and())
  }
  expr
}

///|
/// Parse logical and
fn Parser::parse_and(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_comparison()
  while self.consume(TAnd) {
    expr = @ast.Expr::Operation(
      expr,
      @ast.BinaryOp::And,
      self.parse_comparison(),
    )
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
      @ast.Expr::Operation(expr, @ast.BinaryOp::Equal, self.parse_additive())
    }
    Some(TNeq) => {
      self.advance()
      @ast.Expr::Operation(expr, @ast.BinaryOp::NotEqual, self.parse_additive())
    }
    Some(TLt) => {
      self.advance()
      @ast.Expr::Operation(expr, @ast.BinaryOp::LessThan, self.parse_additive())
    }
    Some(TLe) => {
      self.advance()
      @ast.Expr::Operation(expr, @ast.BinaryOp::LessEq, self.parse_additive())
    }
    Some(TGt) => {
      self.advance()
      @ast.Expr::Operation(
        expr,
        @ast.BinaryOp::GreaterThan,
        self.parse_additive(),
      )
    }
    Some(TGe) => {
      self.advance()
      @ast.Expr::Operation(
        expr,
        @ast.BinaryOp::GreaterEq,
        self.parse_additive(),
      )
    }
    _ => expr
  }
}

///|
/// Parse additive operators
fn Parser::parse_additive(self : Parser) -> @ast.Expr raise ParseError {
  let mut expr = self.parse_multiplicative()
  while true {
    match self.current() {
      Some(TPlus) => {
        self.advance()
        expr = @ast.Expr::Operation(
          expr,
          @ast.BinaryOp::Add,
          self.parse_multiplicative(),
        )
      }
      Some(TMinus) => {
        self.advance()
        expr = @ast.Expr::Operation(
          expr,
          @ast.BinaryOp::Subtract,
          self.parse_multiplicative(),
        )
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
        expr = @ast.Expr::Operation(
          expr,
          @ast.BinaryOp::Multiply,
          self.parse_unary(),
        )
      }
      Some(TSlash) => {
        self.advance()
        expr = @ast.Expr::Operation(
          expr,
          @ast.BinaryOp::Divide,
          self.parse_unary(),
        )
      }
      Some(TPercent) => {
        self.advance()
        expr = @ast.Expr::Operation(
          expr,
          @ast.BinaryOp::Modulo,
          self.parse_unary(),
        )
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
    @ast.Expr::Not
  } else {
    self.parse_postfix()
  }
}
