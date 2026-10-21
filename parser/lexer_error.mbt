///|
/// Lexer error type
pub suberror LexError {
  UnexpectedChar(Int32, Char)
  UnterminatedString(Int32)
  UnterminatedRegion(Int32, String)
  InvalidNumber(Int32, String)
  InvalidEscape(Int32, Char)
} derive(Eq, Debug)

///|
/// Preserve method-style access to derived equality operations.
pub extend LexError with Eq::{not_equal, equal}

///|
/// Preserve method-style access to derived debug representation.
pub extend LexError with @debug.Debug::{to_repr}

///|
pub impl Show for LexError with fn output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
/// Preserve method-style access to display operations.
pub extend LexError with Show::{to_string, output}
