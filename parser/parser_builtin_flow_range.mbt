///|
/// Parse flow range and stream built-ins
fn Parser::parse_builtin_flow_range(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "range" => {
      self.expect(TLParen)
      let first_expr = self.parse_pipe()
      if self.consume(TSemicolon) {
        let second_expr = self.parse_pipe()
        if self.consume(TSemicolon) {
          let third_expr = self.parse_pipe()
          self.expect(TRParen)
          Some(RangeWithStep(first_expr, second_expr, third_expr))
        } else {
          self.expect(TRParen)
          Some(RangeFromTo(first_expr, second_expr))
        }
      } else {
        self.expect(TRParen)
        guard first_expr is Literal(Number(n)) else {
          raise InvalidSyntax("range(n) expects literal number")
        }
        Some(Range(n.to_int()))
      }
    }
    "first" =>
      if self.consume(TLParen) {
        let expr = self.parse_pipe()
        self.expect(TRParen)
        Some(FirstGen(expr))
      } else {
        Some(First)
      }
    "last" =>
      if self.consume(TLParen) {
        let expr = self.parse_pipe()
        self.expect(TRParen)
        Some(LastGen(expr))
      } else {
        Some(Last)
      }
    "repeat" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(Repeat(expr))
    }
    _ => None
  }
}
