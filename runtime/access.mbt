///|
fn check_access(
  input : Value,
  tracking : Bool,
  span : @ast.Span?,
) -> Unit raise EvalError {
  if tracking && input.path is None {
    raise EvalError(Json::string("Invalid path expression"), span)
  }
}

///|
fn access(
  input : Value,
  key : Json,
  tracking : Bool,
  span : @ast.Span?,
) -> Value raise EvalError {
  check_access(input, tracking, span)
  let found = match path_segment(key) {
    Some(segment) => segment.read(input.json)
    None => None
  }
  let json = match found {
    Some(json) => json
    None =>
      raise EvalError(
        Json::string(
          "Cannot index " +
          @ast_internal.json_type_name(input.json) +
          " with " +
          @ast_internal.json_type_name(key),
        ),
        span,
      )
  }
  { json, path: input.path.map(p => p + [key]), }
}

///|
fn each(
  input : Value,
  tracking : Bool,
  span : @ast.Span?,
) -> Machine raise EvalError {
  check_access(input, tracking, span)
  let entries : Iter[(Json, Json)] = match input.json {
    Array(arr) => arr.iter().mapi((i, v) => (Json::number(i.to_double()), v))
    Object(obj) => obj.iter().map(pair => (Json::string(pair.0), pair.1))
    _ =>
      raise EvalError(
        Json::string(
          "Cannot iterate over " + @ast_internal.json_type_name(input.json),
        ),
        span,
      )
  }
  Machine::new(
    Values(
      entries.map(pair => {
        json: pair.1,
        path: input.path.map(p => p + [pair.0]),
      }),
    ),
  )
}

///|
fn path_result(v : Value, span : @ast.Span?) -> Value raise EvalError {
  match v.path {
    Some(path) => value(Json::array(path))
    None => raise EvalError(Json::string("Invalid path expression"), span)
  }
}
