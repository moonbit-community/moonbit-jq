///|
/// Evaluate rounding
fn eval_round(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Number(n, ..) => Iter::singleton(Json::number(n.round()))
    _ => raise TypeMismatch("number", @ast_internal.json_type_name(input))
  }
}

///|
/// Evaluate ceiling
fn eval_ceil(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Number(n, ..) => Iter::singleton(Json::number(n.ceil()))
    _ => raise TypeMismatch("number", @ast_internal.json_type_name(input))
  }
}

///|
/// Evaluate absolute value
fn eval_abs(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Number(n, ..) => Iter::singleton(Json::number(n.abs()))
    _ => raise TypeMismatch("number", @ast_internal.json_type_name(input))
  }
}
