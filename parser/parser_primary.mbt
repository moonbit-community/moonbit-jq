///|
/// Parse primary expressions
fn Parser::parse_primary_inner(self : Parser) -> @ast.Expr raise ParseError {
  match self.current() {
    Some(TNull) => {
      self.advance()
      Literal(Null)
    }
    Some(TTrue) => {
      self.advance()
      Literal(Bool(true))
    }
    Some(TFalse) => {
      self.advance()
      Literal(Bool(false))
    }
    Some(TNumber(n)) => {
      self.advance()
      Literal(Number(n))
    }
    Some(TStringStart) => self.parse_string()
    Some(TField(name)) => {
      self.advance()
      Key(name)
    }
    Some(TDotDot) => {
      self.advance()
      FunctionCall("recurse", [])
    }
    Some(TDot) => {
      self.advance()
      match self.current() {
        Some(TStringStart) => Subscript(Identity, self.parse_string())
        Some(TLBracket) => {
          self.advance()
          self.parse_index_or_slice(Identity)
        }
        _ => Identity
      }
    }
    Some(TVariable(name)) => {
      self.advance()
      Variable(name)
    }
    Some(TFormat(name)) => {
      self.advance()
      Format(name)
    }
    Some(TLParen) => {
      self.advance()
      let expr = self.parse_definitions()
      self.expect(TRParen)
      expr
    }
    Some(TLBracket) => {
      self.advance()
      if self.consume(TRBracket) {
        ArrayConstruct(None)
      } else {
        let expr = self.parse_definitions()
        self.expect(TRBracket)
        ArrayConstruct(Some(expr))
      }
    }
    Some(TLBrace) => {
      self.advance()
      self.parse_object()
    }
    Some(TIf) => self.parse_if()
    Some(TTry) => self.parse_try()
    Some(TReduce) => self.parse_reduce()
    Some(TForeach) => self.parse_foreach()
    Some(TIdentifier(name)) => {
      self.advance()
      self.parse_builtin(name)
    }
    Some(t) => raise UnexpectedToken(t.to_string(), "expression")
    None => raise UnexpectedEnd("expression")
  }
}

///|
fn Parser::parse_string(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.expect(TStringStart)
  let parts : Array[(String, @ast.Expr?)] = []
  while !self.check(TStringEnd) {
    match self.current() {
      Some(TStringText(text)) => {
        self.advance()
        parts.push((text, None))
      }
      Some(TInterpolationStart) => {
        self.advance()
        let expr = self.parse_definitions()
        self.expect(TInterpolationEnd)
        parts.push(("", Some(expr)))
      }
      _ => raise InvalidSyntax("Expected string text or interpolation")
    }
  }
  self.expect(TStringEnd)
  let expr : @ast.Expr = match parts {
    [] => Literal(String(""))
    [(text, None)] => Literal(String(text))
    _ => StringInterpolation(parts)
  }
  self.located(start, expr)
}

///|
fn Parser::parse_primary(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_primary_inner())
}
