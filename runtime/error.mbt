///|
/// A query failure, carrying the original JSON error value and optional source span.
pub(all) suberror EvalError {
  EvalError(Json, @ast.Span?)
} derive(Debug)

///|
/// The JSON value passed to `catch`.
pub fn EvalError::value(self : EvalError) -> Json {
  let EvalError(value, _) = self
  value
}

///|
/// UTF-16 source offsets of the failing expression, if available.
pub fn EvalError::span(self : EvalError) -> @ast.Span? {
  let EvalError(_, span) = self
  span
}

///|
pub impl Show for EvalError with fn output(self, logger) {
  logger.write_string(json_to_display_string(self.value()))
  if self.span() is Some(span) {
    logger.write_string(" at UTF-16 \{span.start}..\{span.end}")
  }
}

///|
fn primitive_error(error : PrimitiveError, span : @ast.Span?) -> EvalError {
  let message = match error {
    TypeMismatch(expected, got) => "Expected " + expected + ", got " + got
    InvalidOperation(message) | TypeError(message) => message
    DivisionByZero => "Division by zero"
  }
  EvalError(Json::string(message), span)
}

///|
pub extend EvalError with @debug.Debug::{to_repr}

///|
pub extend EvalError with Show::{to_string, output}
