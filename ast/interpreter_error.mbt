///|
/// Interpreter error types
pub(all) suberror InterpreterError {
  TypeMismatch(String, String) // (expected, got)
  KeyNotFound(String)
  IndexOutOfBounds(Int)
  InvalidOperation(String)
  DivisionByZero
  TypeError(String)
  EvalError(String)
} derive(Eq, Debug)

///|
/// Preserve method-style access to derived equality operations.
pub extend InterpreterError with Eq::{not_equal, equal}

///|
/// Preserve method-style access to derived debug representation.
pub extend InterpreterError with @debug.Debug::{to_repr}

///|
pub impl Show for InterpreterError with fn output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
/// Preserve method-style access to display operations.
pub extend InterpreterError with Show::{to_string, output}
