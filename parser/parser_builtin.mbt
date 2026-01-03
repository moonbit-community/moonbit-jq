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
        if not(self.current() == Some(TRParen)) {
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
/// Parse built-ins by category
fn Parser::parse_builtin_by_name(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match self.parse_builtin_core(name) {
    Some(expr) => Some(expr)
    None =>
      match self.parse_builtin_numeric(name) {
        Some(expr) => Some(expr)
        None =>
          match self.parse_builtin_array(name) {
            Some(expr) => Some(expr)
            None =>
              match self.parse_builtin_object(name) {
                Some(expr) => Some(expr)
                None =>
                  match self.parse_builtin_string(name) {
                    Some(expr) => Some(expr)
                    None =>
                      match self.parse_builtin_path(name) {
                        Some(expr) => Some(expr)
                        None => self.parse_builtin_flow(name)
                      }
                  }
              }
          }
      }
  }
}
