///|
/// Evaluate left trim
fn eval_ltrim_str(
  prefix : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  match s.strip_prefix(prefix[:]) {
    Some(rest) => Iter::singleton(Json::string(rest.to_string()))
    None => Iter::singleton(input)
  }
}

///|
/// Evaluate right trim
fn eval_rtrim_str(
  suffix : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  match s.strip_suffix(suffix[:]) {
    Some(rest) => Iter::singleton(Json::string(rest.to_string()))
    None => Iter::singleton(input)
  }
}

///|
/// Evaluate ASCII upcase
fn eval_ascii_upcase(input : Json) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  let result = @buffer.new()
  for ch in s {
    if ch is ('a'..='z') {
      result.write_char(Int::unsafe_to_char(ch.to_int() - 32))
    } else {
      result.write_char(ch)
    }
  }
  Iter::singleton(Json::string(result.to_string()))
}

///|
/// Evaluate ASCII downcase
fn eval_ascii_downcase(input : Json) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  let result = @buffer.new()
  for ch in s {
    if ch is ('A'..='Z') {
      result.write_char(Int::unsafe_to_char(ch.to_int() + 32))
    } else {
      result.write_char(ch)
    }
  }
  Iter::singleton(Json::string(result.to_string()))
}
