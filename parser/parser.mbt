///|
/// Parse entry point
pub fn parse(input : String) -> @ast.Expr raise {
  let tokens = lex(input)
  let parser = Parser::new(tokens)
  parser.parse_definitions()
}

///|
/// Parse function definitions followed by expression
fn Parser::parse_definitions(self : Parser) -> @ast.Expr raise ParseError {
  let defs : Array[@ast.Expr] = []
  while self.current() == Some(TDef) {
    defs.push(self.parse_function_def())
  }
  let main_expr = self.parse_pipe()
  // The whole query must be consumed; otherwise `. 1` or `."a"` would
  // silently parse as `.`.
  if self.current() is Some(t) && !(t is TEof) {
    raise UnexpectedToken(t.to_string(), "end of query")
  }
  // Chain definitions with main expression so they execute in order
  match defs {
    [] => main_expr
    // Fold defs from right to left so they execute in order
    _ => defs.rev().fold(init=main_expr, fn(expr, def) { Pipe(def, expr) })
  }
}
