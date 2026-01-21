///|
/// Parse built-in functions
fn Parser::parse_builtin(
  self : Parser,
  name : String,
) -> @ast.Expr raise ParseError {
  match self.parse_builtin_by_name(name) {
    Some(expr) => expr
    None =>
      if self.current() == Some(TLParen) {
        self.advance()
        let args : Array[@ast.Expr] = []
        // Check if there's an expression (not just closing paren)
        if self.current() != Some(TRParen) {
          args.push(self.parse_pipe())
          while self.consume(TSemicolon) {
            args.push(self.parse_pipe())
          }
        }
        self.expect(TRParen)
        @ast.Expr::FunctionCall(name, args)
      } else {
        @ast.Expr::FunctionCall(name, [])
      }
  }
}

///|
/// Parse built-ins by category - try each category in order
fn Parser::parse_builtin_by_name(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  if self.parse_builtin_core(name) is Some(expr) {
    return Some(expr)
  }
  if self.parse_builtin_numeric(name) is Some(expr) {
    return Some(expr)
  }
  if self.parse_builtin_array(name) is Some(expr) {
    return Some(expr)
  }
  if self.parse_builtin_object(name) is Some(expr) {
    return Some(expr)
  }
  if self.parse_builtin_string(name) is Some(expr) {
    return Some(expr)
  }
  if self.parse_builtin_path(name) is Some(expr) {
    return Some(expr)
  }
  self.parse_builtin_flow(name)
}
