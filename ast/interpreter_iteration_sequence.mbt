///|
/// Evaluate range
fn eval_range(n : Int) -> Iter[Json] {
  if n <= 0 {
    Iter::empty()
  } else {
    Array::makei(n, i => Json::number(i.to_double())).iter()
  }
}

///|
/// Evaluate first element
///
/// jq defines `first` as `.[0]`, so an empty array (or null) gives null.
fn eval_first(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Array(arr) => Iter::singleton(arr.get(0).unwrap_or(null))
    Null => Iter::singleton(null)
    _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
}

///|
/// Evaluate last element
///
/// jq defines `last` as `.[-1]`, so an empty array (or null) gives null.
fn eval_last(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Array(arr) => Iter::singleton(arr.last().unwrap_or(null))
    Null => Iter::singleton(null)
    _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
}
