///|
/// Parser error types
pub(all) suberror ParseError {
  UnexpectedToken(String, String) // (found, expected) - using String to avoid ToJson requirement
  UnexpectedEnd(String) // (expected)
  InvalidSyntax(String)
  InvalidExpression(String)
} derive(Eq, Debug)

///|
pub impl Show for ParseError with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}
