///|
/// Evaluate range
fn eval_range(n : Int) -> Iter[Json] {
  if n <= 0 {
    [].iter()
  } else {
    Array::makei(n, i => Json::number(i.to_double())).iter()
  }
}

///|
/// Evaluate first element
fn eval_first(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Array(arr) =>
      match arr[:] {
        [] => Iter::empty()
        [head, ..] => Iter::singleton(head)
      }
    _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
}

///|
/// Evaluate last element
fn eval_last(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Array(arr) =>
      match last_in_view(arr[:]) {
        Some(value) => Iter::singleton(value)
        None => Iter::empty()
      }
    _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
}

///|
fn last_in_view(arr : ArrayView[Json]) -> Json? {
  match arr {
    [] => None
    [head] => Some(head)
    [_head, .. tail] => last_in_view(tail)
  }
}
