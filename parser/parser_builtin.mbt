///|
/// Calls have one syntax; name resolution and argument modes belong to compilation.
fn Parser::parse_builtin(
  self : Parser,
  name : String,
) -> @ast.Expr raise ParseError {
  let args : Array[@ast.Expr] = []
  if self.consume(TLParen) {
    if self.check(TRParen) {
      raise InvalidSyntax("Expected argument")
    }
    args.push(self.parse_definitions())
    while self.consume(TSemicolon) {
      args.push(self.parse_definitions())
    }
    self.expect(TRParen)
  }
  FunctionCall(name, args)
}
