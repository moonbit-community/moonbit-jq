///|
/// Evaluate regex test (simple contains)
fn eval_test(
  pattern : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  Iter::singleton(Json::boolean(s.contains(pattern)))
}

///|
/// Evaluate regex match (simple contains)
fn eval_match(
  pattern : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  if s.contains(pattern) {
    Iter::singleton(
      Json::object(
        Map::from_array([
          ("match", Json::string(pattern)),
          ("offset", Json::number(0.0)),
          ("length", Json::number(pattern.length().to_double())),
          ("string", Json::string(s)),
          ("captures", Json::array([])),
        ]),
      ),
    )
  } else {
    Iter::empty()
  }
}

///|
/// Evaluate regex capture (placeholder)
fn eval_capture(
  _pattern : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(_) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  Iter::singleton(Json::object(Map::from_array([])))
}

///|
/// Evaluate regex splits (simple split)
fn eval_splits(
  pattern : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  let parts = s.split(pattern).collect()
  parts.iter().map(part => Json::string(part.to_string()))
}

///|
/// Evaluate regex sub (simple replace)
fn eval_sub(
  pattern : String,
  replacement : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  Iter::singleton(Json::string(s.replace(old=pattern[:], new=replacement[:])))
}

///|
/// Evaluate regex gsub (simple replace all)
fn eval_gsub(
  pattern : String,
  replacement : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  Iter::singleton(
    Json::string(s.replace_all(old=pattern[:], new=replacement[:])),
  )
}
