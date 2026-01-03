///|
/// Parse object built-ins
fn Parser::parse_builtin_object(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "has" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(key)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Has(key))
        }
        Some(TNumber(n)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Has(n.to_string()))
        }
        _ => raise InvalidSyntax("has expects string or number argument")
      }
    }
    "in" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::In(expr))
    }
    "to_entries" => Some(@ast.Expr::ToEntries)
    "from_entries" => Some(@ast.Expr::FromEntries)
    "with_entries" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::WithEntries(expr))
    }
    "map_values" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::MapValues(expr))
    }
    _ => None
  }
}
