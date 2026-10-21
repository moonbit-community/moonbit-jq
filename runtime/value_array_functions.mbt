///|
/// Evaluate array sort
fn eval_sort(input : Json) -> Iter[Json] raise PrimitiveError {
  guard input is Array(arr) else {
    raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
  let sorted = arr.copy()
  sorted.sort_by(compare_json)
  Iter::singleton(Json::array(sorted))
}

///|
/// Evaluate array reverse
fn eval_reverse(input : Json) -> Iter[Json] raise PrimitiveError {
  guard input is Array(arr) else {
    raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
  Iter::singleton(Json::array(arr.rev()))
}

///|
/// Evaluate array flatten
fn eval_flatten(
  depth_opt : Int32?,
  input : Json,
) -> Iter[Json] raise PrimitiveError {
  guard input is Array(arr) else {
    raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
  let depth = depth_opt.unwrap_or(999999) // Flatten all levels
  Iter::singleton(Json::array(flatten_array(arr, depth)))
}

///|
/// Evaluate array unique
fn eval_unique(input : Json) -> Iter[Json] raise PrimitiveError {
  guard input is Array(arr) else {
    raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
  let sorted = arr.copy()
  sorted.sort_by(compare_json)
  let (unique, _prev) : (Array[Json], Json?) = sorted.fold(init=([], None), fn(
    state,
    elem,
  ) {
    let (acc, prev) = state
    match prev {
      None => {
        acc.push(elem)
        (acc, Some(elem))
      }
      Some(p) =>
        if compare_json(p, elem) != 0 {
          acc.push(elem)
          (acc, Some(elem))
        } else {
          (acc, prev)
        }
    }
  })
  Iter::singleton(Json::array(unique))
}
