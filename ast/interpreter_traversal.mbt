///|
/// Flatten array to specified depth
fn flatten_array_into(
  arr : Array[Json],
  depth : Int,
  out : Array[Json],
) -> Unit {
  if depth <= 0 {
    for elem in arr {
      out.push(elem)
    }
    return
  }
  for elem in arr {
    match elem {
      Array(inner) => flatten_array_into(inner, depth - 1, out)
      _ => out.push(elem)
    }
  }
}

///|
fn flatten_array(arr : Array[Json], depth : Int) -> Array[Json] {
  if depth <= 0 {
    return arr
  }
  let result : Array[Json] = []
  flatten_array_into(arr, depth, result)
  result
}

///|
/// Recursive descent: yield input and all nested values
fn recurse_all(input : Json) -> Iterator[Json] {
  match input {
    Array(arr) =>
      Iterator::singleton(input).concat(arr.iterator().flat_map(recurse_all))
    Object(obj) => {
      let values : Array[Json] = []
      for _k, v in obj {
        values.push(v)
      }
      Iterator::singleton(input).concat(values.iterator().flat_map(recurse_all))
    }
    _ => Iterator::singleton(input)
  }
}
