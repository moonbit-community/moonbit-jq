///|
/// Evaluate to_entries
fn eval_to_entries(input : Json) -> Iter[Json] raise PrimitiveError {
  match input {
    Object(obj) => {
      let entries = obj
        .iter()
        .map(fn(pair) { entry_from_pair(Json::string(pair.0), pair.1) })
        .collect()
      Iter::singleton(Json::array(entries))
    }
    Array(arr) =>
      Iter::singleton(
        Json::array(
          arr.mapi(fn(i, v) { entry_from_pair(Json::number(i.to_double()), v) }),
        ),
      )
    _ => raise TypeMismatch("object/array", @ast_internal.json_type_name(input))
  }
}

///|
/// Evaluate from_entries
fn eval_from_entries(input : Json) -> Iter[Json] raise PrimitiveError {
  match input {
    Array(arr) =>
      Iter::singleton(
        Json::object(Map::from_array(arr.filter_map(entry_to_pair))),
      )
    _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
}

///|
fn entry_from_pair(key : Json, value : Json) -> Json {
  let entry : Map[String, Json] = { "key": key, "value": value }
  Json::object(entry)
}

///|
fn entry_to_pair(entry : Json) -> (String, Json)? {
  guard entry is Object(obj) else { return None }
  guard obj.get("value") is Some(value) else { return None }
  match obj.get("key") {
    Some(String(key_str)) => Some((key_str, value))
    Some(Number(n, ..)) => Some((n.to_int().to_string(), value))
    _ =>
      match obj.get("name") {
        Some(String(key_str)) => Some((key_str, value))
        Some(Number(n, ..)) => Some((n.to_int().to_string(), value))
        _ => None
      }
  }
}
