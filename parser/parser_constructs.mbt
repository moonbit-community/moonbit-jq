///|
/// Parse object constructor
fn Parser::parse_object(self : Parser) -> @ast.Expr raise ParseError {
  if self.consume(TRBrace) {
    return ObjectConstruct([])
  }
  let pairs : Array[(@ast.Expr, @ast.Expr?)] = []
  while true {
    let key : @ast.Expr = match self.current() {
      Some(TStringStart) => self.parse_string()
      Some(t) if t.name() is Some(_) => {
        let name = t.name().unwrap()
        self.advance()
        Literal(String(name))
      }
      Some(TLParen) => {
        self.advance()
        let expr = self.parse_pipe()
        self.expect(TRParen)
        expr
      }
      _ => raise InvalidSyntax("Expected object key")
    }
    let value = if self.consume(TColon) {
      Some(self.parse_object_value())
    } else {
      None
    }
    pairs.push((key, value))
    if !self.consume(TComma) || self.check(TRBrace) {
      break
    }
  }
  self.expect(TRBrace)
  ObjectConstruct(pairs)
}

///|
/// Parse if-then-else
fn Parser::parse_if(self : Parser) -> @ast.Expr raise ParseError {
  self.advance()
  let cond = self.parse_pipe()
  self.expect(TThen)
  let then_expr = self.parse_definitions()
  let else_expr = if self.consume(TElse) {
    let expr = self.parse_definitions()
    self.expect(TEnd)
    expr
  } else if self.check(TElif) {
    self.parse_if()
  } else {
    self.expect(TEnd)
    Identity
  }
  IfThenElse(cond, then_expr, else_expr)
}

///|
/// Parse try-catch
fn Parser::parse_try(self : Parser) -> @ast.Expr raise ParseError {
  self.advance()
  let expr = self.parse_postfix()
  let handler = if self.consume(TCatch) {
    Some(self.parse_postfix())
  } else {
    None
  }
  TryCatch(expr, handler)
}

///|
/// Parse reduce: reduce EXPR as $VAR (INIT; UPDATE)
fn Parser::parse_reduce(self : Parser) -> @ast.Expr raise ParseError {
  self.advance() // consume 'reduce'
  let gen_expr = self.parse_postfix() // generator expression
  // Expect 'as $var'
  guard self.consume(TAs) else {
    raise InvalidSyntax("reduce expects 'as' after expression")
  }
  guard self.current() is Some(TVariable(var_name)) else {
    raise InvalidSyntax("reduce expects variable after as")
  }
  self.advance()
  // Expect (INIT; UPDATE)
  self.expect(TLParen)
  let init_expr = self.parse_pipe()
  self.expect(TSemicolon)
  let update_expr = self.parse_pipe()
  self.expect(TRParen)
  Reduce(gen_expr, var_name, init_expr, update_expr)
}

///|
/// Parse foreach: foreach EXPR as $VAR (INIT; UPDATE) or (INIT; UPDATE; EXTRACT)
fn Parser::parse_foreach(self : Parser) -> @ast.Expr raise ParseError {
  self.advance() // consume 'foreach'
  let gen_expr = self.parse_postfix() // generator expression
  // Expect 'as $var'
  guard self.consume(TAs) else {
    raise InvalidSyntax("foreach expects 'as' after expression")
  }
  guard self.current() is Some(TVariable(var_name)) else {
    raise InvalidSyntax("foreach expects variable after as")
  }
  self.advance()
  // Expect (INIT; UPDATE) or (INIT; UPDATE; EXTRACT)
  self.expect(TLParen)
  let init_expr = self.parse_pipe()
  self.expect(TSemicolon)
  let update_expr = self.parse_pipe()
  // Check for optional extract expression
  let extract_expr = if self.consume(TSemicolon) {
    Some(self.parse_pipe())
  } else {
    None
  }
  self.expect(TRParen)
  Foreach(gen_expr, var_name, init_expr, update_expr, extract_expr)
}

///|
fn Parser::parse_object_value(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  let left = self.parse_assignment()
  if self.consume(TPipe) {
    self.located(start, Pipe(left, self.parse_object_value()))
  } else {
    left
  }
}
