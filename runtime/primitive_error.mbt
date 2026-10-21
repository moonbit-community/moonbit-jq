///|
priv suberror PrimitiveError {
  TypeMismatch(String, String)
  InvalidOperation(String)
  DivisionByZero
  TypeError(String)
} derive(Debug)
