///|
/// Parse assignment operators
fn Parser::parse_assignment(self : Parser) -> @ast.Expr raise ParseError {
  let expr = self.parse_or()
  match self.current() {
    Some(TAssign) => {
      self.advance()
      Assign(expr, self.parse_or())
    }
    Some(TUpdate) => {
      self.advance()
      Update(expr, self.parse_or())
    }
    Some(TAlternative) => {
      self.advance()
      Alternative(expr, self.parse_or())
    }
    Some(TAddAssign) => {
      self.advance()
      AddAssign(expr, self.parse_or())
    }
    Some(TSubAssign) => {
      self.advance()
      SubAssign(expr, self.parse_or())
    }
    Some(TMulAssign) => {
      self.advance()
      MulAssign(expr, self.parse_or())
    }
    Some(TDivAssign) => {
      self.advance()
      DivAssign(expr, self.parse_or())
    }
    Some(TModAssign) => {
      self.advance()
      ModAssign(expr, self.parse_or())
    }
    Some(TAltAssign) => {
      self.advance()
      AltAssign(expr, self.parse_or())
    }
    _ => expr
  }
}
