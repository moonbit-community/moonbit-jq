///|
/// Parse array built-ins
fn Parser::parse_builtin_array(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "map" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::Map(expr))
    }
    "select" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::Select(expr))
    }
    "sort" => Some(@ast.Expr::Sort)
    "reverse" => Some(@ast.Expr::Reverse)
    "flatten" =>
      if self.consume(TLParen) {
        match self.current() {
          Some(TNumber(n)) => {
            self.advance()
            self.expect(TRParen)
            Some(@ast.Expr::Flatten(Some(n.to_int())))
          }
          _ => {
            self.expect(TRParen)
            Some(@ast.Expr::Flatten(None))
          }
        }
      } else {
        Some(@ast.Expr::Flatten(None))
      }
    "unique" => Some(@ast.Expr::Unique)
    "unique_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::UniqueBy(expr))
    }
    "combinations" => Some(@ast.Expr::Combinations)
    "transpose" => Some(@ast.Expr::Transpose)
    "indices" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::IndicesOf(expr))
    }
    "index" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::IndexOf(expr))
    }
    "sort_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::SortBy(expr))
    }
    "group_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::GroupBy(expr))
    }
    "nth" => {
      self.expect(TLParen)
      match self.current() {
        Some(TNumber(n)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Nth(n.to_int()))
        }
        _ => raise InvalidSyntax("nth expects number argument")
      }
    }
    "rindex" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::RIndex(expr))
    }
    _ => None
  }
}
