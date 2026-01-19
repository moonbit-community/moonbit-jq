///|
/// Evaluate length
fn eval_length(input : Json) -> Iter[Json] raise InterpreterError {
  let len = match input {
    Array(arr) => arr.length()
    Object(obj) => obj.length()
    String(s) => s.length()
    Null => 0
    _ =>
      raise TypeMismatch(
        "array/object/string",
        @ast_internal.json_type_name(input),
      )
  }
  Iter::singleton(Json::number(len.to_double()))
}

///|
/// Evaluate keys
fn eval_keys(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Object(obj) => {
      let keys : Array[Json] = []
      for k, _v in obj {
        keys.push(Json::string(k))
      }
      Iter::singleton(Json::array(keys))
    }
    Array(arr) => {
      let indices = arr.mapi((i, _) => Json::number(i.to_double()))
      Iter::singleton(Json::array(indices))
    }
    _ => raise TypeMismatch("object/array", @ast_internal.json_type_name(input))
  }
}

///|
/// Evaluate values
fn eval_values(input : Json) -> Iter[Json] raise InterpreterError {
  match input {
    Object(obj) => {
      let values : Array[Json] = []
      for _k, v in obj {
        values.push(v)
      }
      Iter::singleton(Json::array(values))
    }
    Array(arr) => Iter::singleton(Json::array(arr))
    _ => raise TypeMismatch("object/array", @ast_internal.json_type_name(input))
  }
}

///|
/// Evaluate type
fn eval_type(input : Json) -> Iter[Json] {
  Iter::singleton(Json::string(@ast_internal.json_type_name(input)))
}

///|
/// Evaluate empty
fn eval_empty() -> Iter[Json] {
  Iter::empty()
}

///|
/// Evaluate logical not
fn eval_not(input : Json) -> Iter[Json] {
  Iter::singleton(Json::boolean(not(@ast_internal.is_truthy(input))))
}
