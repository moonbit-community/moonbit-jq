///|
/// Parse path built-ins
fn Parser::parse_builtin_path(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "paths" =>
      if self.consume(TLParen) {
        let expr = self.parse_pipe()
        self.expect(TRParen)
        Some(PathsWithFilter(expr))
      } else {
        Some(Paths)
      }
    "leaf_paths" => Some(LeafPaths)
    "getpath" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(GetPath(expr))
    }
    "setpath" => {
      self.expect(TLParen)
      let path = self.parse_pipe()
      self.expect(TSemicolon)
      let value = self.parse_pipe()
      self.expect(TRParen)
      Some(SetPath(path, value))
    }
    "delpaths" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(DelPaths(expr))
    }
    _ => None
  }
}
