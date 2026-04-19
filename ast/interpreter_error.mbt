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
pub impl Show for InterpreterError with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}
