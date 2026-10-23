///|
/// Parse postfix operators
fn Parser::parse_postfix_inner(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  let mut expr = self.parse_primary()
  while true {
    match self.current() {
      Some(TQuestion) => {
        self.advance()
        expr = self.located(start, Optional(expr))
        continue
      }
      Some(TLBracket) => {
        self.advance()
        expr = self.located(start, self.parse_index_or_slice(expr))
        continue
      }
      Some(TField(name)) => {
        self.advance()
        expr = self.located(
          start,
          Pipe(expr, self.located(self.pos - 1, Key(name))),
        )
        continue
      }
      Some(TDot) => {
        self.advance()
        expr = self.located(start, self.parse_field_access(expr))
        continue
      }
      _ => break
    }
  }
  expr
}

///|
/// Parse array index or slice
fn Parser::parse_index_or_slice(
  self : Parser,
  base : @ast.Expr,
) -> @ast.Expr raise ParseError {
  let start = self.pos - 1
  if self.consume(TRBracket) {
    return Pipe(base, self.located(start, Index([])))
  }
  let left = if self.check(TColon) { None } else { Some(self.parse_pipe()) }
  if self.consume(TColon) {
    let right = if self.check(TRBracket) {
      None
    } else {
      Some(self.parse_pipe())
    }
    self.expect(TRBracket)
    fn integer(expr : @ast.Expr?) -> Int32? raise ParseError {
      match expr {
        None => None
        Some(Located(_, e)) => integer(Some(e))
        Some(Literal(Number(n))) => Some(n.to_int())
        _ => raise InvalidSyntax("Slice bounds must be integers")
      }
    }
    Pipe(base, self.located(start, Slice(integer(left), integer(right))))
  } else {
    self.expect(TRBracket)
    Subscript(base, left.unwrap())
  }
}

///|
/// Parse field access after dot
fn Parser::parse_field_access(
  self : Parser,
  base : @ast.Expr,
) -> @ast.Expr raise ParseError {
  match self.current() {
    Some(TStringStart) => Subscript(base, self.parse_string())
    Some(TLBracket) => {
      self.advance()
      self.parse_index_or_slice(base)
    }
    _ => raise InvalidSyntax("Expected field after dot")
  }
}

///|
fn Parser::parse_postfix(self : Parser) -> @ast.Expr raise ParseError {
  let start = self.pos
  self.located(start, self.parse_postfix_inner())
}
