///|
/// Evaluate Explode
fn eval_explode(input : Json) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  let results = s
    .iter()
    .map(fn(char) { Json::number(char.to_int().to_double()) })
    .to_array()
  Iter::singleton(Json::array(results))
}

///|
/// Evaluate Implode
fn eval_implode(input : Json) -> Iter[Json] raise InterpreterError {
  guard input is Array(arr) else {
    raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
  let chars = arr.filter_map(fn(elem) {
    match elem {
      Number(n, ..) => Int::to_char(n.to_int())
      _ => None
    }
  })
  let result = String::from_array(chars)
  Iter::singleton(Json::string(result))
}

///|
/// Evaluate Scan
fn eval_scan(
  pattern : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  guard input is String(s) else {
    raise TypeMismatch("string", @ast_internal.json_type_name(input))
  }
  let results : Array[Json] = []
  scan_matches(s, pattern, 0, s.length(), pattern.length(), results)
  results.iter()
}

///|
fn scan_matches(
  s : String,
  pattern : String,
  idx : Int,
  slen : Int,
  plen : Int,
  results : Array[Json],
) -> Unit {
  if plen == 0 {
    return
  }
  let mut pos = idx
  let last = slen - plen
  while pos <= last {
    if is_string_boundary(s, pos) &&
      is_string_boundary(s, pos + plen) &&
      s[pos:pos + plen].to_string() == pattern {
      results.push(Json::string(pattern))
      pos += plen
    } else {
      pos = next_string_index(s, pos)
    }
  }
}

///|
fn is_string_boundary(s : String, index : Int) -> Bool {
  index == 0 ||
  index == s.length() ||
  !s.unsafe_get(index).is_trailing_surrogate()
}

///|
fn next_string_index(s : String, index : Int) -> Int {
  if index < s.length() && s.unsafe_get(index).is_leading_surrogate() {
    index + 2
  } else {
    index + 1
  }
}
