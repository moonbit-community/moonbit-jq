///|
/// Parser error types
pub(all) suberror ParseError {
  UnexpectedToken(String, String) // (found, expected) - using String to avoid ToJson requirement
  UnexpectedEnd(String) // (expected)
  InvalidSyntax(String)
  InvalidExpression(String)
} derive(Eq, Debug)

///|
/// Preserve method-style access to derived equality operations.
pub extend ParseError with Eq::{not_equal, equal}

///|
/// Preserve method-style access to derived debug representation.
pub extend ParseError with @debug.Debug::{to_repr}

///|
pub impl Show for ParseError with fn output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
/// Preserve method-style access to display operations.
pub extend ParseError with Show::{to_string, output}
