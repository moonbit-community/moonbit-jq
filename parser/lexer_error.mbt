///|
/// Lexer error type
pub suberror LexError {
  UnexpectedChar(Int, Char)
  UnterminatedString(Int)
  InvalidNumber(Int, String)
  InvalidEscape(Int, Char)
} derive(Eq, Debug)

///|
pub impl Show for LexError with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}
