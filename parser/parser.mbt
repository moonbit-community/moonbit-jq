///|
/// Parse exactly one query, retaining original UTF-16 source locations.
pub fn parse(input : String) -> @ast.Expr raise {
  let tokens = lex_spanned(input)
  let parser = Parser::new(
    tokens.map(t => t.token),
    spans=tokens.map(t => t.span),
  )
  try {
    let expr = parser.parse_definitions()
    parser.expect(TEof)
    complete_locations(expr, { start: 0, end: input.length(), })
  } catch {
    err =>
      raise Diagnostic(
        err.to_string(),
        parser.spans
        .get(parser.pos)
        .unwrap_or({ start: input.length(), end: input.length(), }),
      )
  }
}

///|
fn Parser::parse_definitions(self : Parser) -> @ast.Expr raise ParseError {
  if self.current() == Some(TDef) {
    let start = self.pos
    let def = self.parse_function_def()
    let rest = self.parse_definitions()
    match def {
      FunctionDef(name, params, body) =>
        self.located(start, Scope(name, params, body, rest))
      _ => raise InvalidSyntax("Expected function definition")
    }
  } else {
    self.parse_pipe()
  }
}
