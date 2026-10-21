///|
/// Evaluate string split
fn eval_split(sep : String, input : Json) -> Iter[Json] raise PrimitiveError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  let parts = s.split(sep).collect()
  let json_parts = string_views_to_json(parts)
  Iter::singleton(Json::array(json_parts))
}

///|
/// Evaluate string join
fn eval_join(sep : String, input : Json) -> Iter[Json] raise PrimitiveError {
  guard input is Array(arr) else {
    raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
  let parts = json_to_strings(arr)
  Iter::singleton(Json::string(parts.join(sep)))
}

///|
/// Evaluate prefix check
fn eval_starts_with(
  prefix : String,
  input : Json,
) -> Iter[Json] raise PrimitiveError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  Iter::singleton(Json::boolean(s.has_prefix(prefix)))
}

///|
/// Evaluate suffix check
fn eval_ends_with(
  suffix : String,
  input : Json,
) -> Iter[Json] raise PrimitiveError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  Iter::singleton(Json::boolean(s.has_suffix(suffix)))
}

///|
fn string_views_to_json(parts : ArrayView[StringView]) -> Array[Json] {
  parts.map(fn(part) { Json::string(part.to_owned()) })
}

///|
fn json_to_strings(parts : ArrayView[Json]) -> Array[String] {
  parts.map(fn(part) {
    match part {
      String(s) => s
      Null => ""
      _ => json_to_text(part)
    }
  })
}
