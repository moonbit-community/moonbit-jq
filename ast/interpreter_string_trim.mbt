///|
/// Evaluate left trim
fn eval_ltrim_str(
  prefix : String,
  input : Json,
) -> Iterator[Json] raise InterpreterError {
  match input {
    String(s) =>
      match s.strip_prefix(prefix[:]) {
        Some(rest) => Iterator::singleton(Json::string(rest.to_string()))
        None => Iterator::singleton(input)
      }
    _ => raise TypeMismatch("string", json_type_name(input))
  }
}

///|
/// Evaluate right trim
fn eval_rtrim_str(
  suffix : String,
  input : Json,
) -> Iterator[Json] raise InterpreterError {
  match input {
    String(s) =>
      match s.strip_suffix(suffix[:]) {
        Some(rest) => Iterator::singleton(Json::string(rest.to_string()))
        None => Iterator::singleton(input)
      }
    _ => raise TypeMismatch("string", json_type_name(input))
  }
}

///|
/// Evaluate ASCII upcase
fn eval_ascii_upcase(input : Json) -> Iterator[Json] raise InterpreterError {
  match input {
    String(s) => {
      let result = @buffer.new()
      for ch in s {
        if ch >= 'a' && ch <= 'z' {
          result.write_char(Int::unsafe_to_char(ch.to_int() - 32))
        } else {
          result.write_char(ch)
        }
      }
      Iterator::singleton(Json::string(result.to_string()))
    }
    _ => raise TypeMismatch("string", json_type_name(input))
  }
}

///|
/// Evaluate ASCII downcase
fn eval_ascii_downcase(input : Json) -> Iterator[Json] raise InterpreterError {
  match input {
    String(s) => {
      let result = @buffer.new()
      for ch in s {
        if ch >= 'A' && ch <= 'Z' {
          result.write_char(Int::unsafe_to_char(ch.to_int() + 32))
        } else {
          result.write_char(ch)
        }
      }
      Iterator::singleton(Json::string(result.to_string()))
    }
    _ => raise TypeMismatch("string", json_type_name(input))
  }
}
