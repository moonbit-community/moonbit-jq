///|
/// Flatten array to specified depth
fn flatten_array_into(
  arr : Array[Json],
  depth : Int32,
  out : Array[Json],
) -> Unit {
  guard depth > 0 else {
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
fn flatten_array(arr : Array[Json], depth : Int32) -> Array[Json] {
  guard depth > 0 else { return arr }
  let result : Array[Json] = []
  flatten_array_into(arr, depth, result)
  result
}
