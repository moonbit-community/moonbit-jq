///|
/// Evaluate field access against input JSON
fn eval_key_access(key : String, input : Json) -> Iter[Json] {
  match input {
    Object(obj) =>
      match obj.get(key) {
        Some(v) => Iter::singleton(v)
        None => Iter::singleton(null)
      }
    _ => Iter::singleton(null)
  }
}

///|
/// Evaluate array indexing and iteration
fn eval_index_access(indices : Array[Int], input : Json) -> Iter[Json] {
  if indices.is_empty() {
    // Empty index means iterate over array/object values
    match input {
      Array(arr) => arr.iter()
      Object(obj) => obj.values()
      _ => Iter::empty()
    }
  } else {
    // Multiple indices produce multiple results
    indices
    .iter()
    .map(fn(idx) {
      match input {
        Array(arr) => {
          let i = if idx < 0 { arr.length() + idx } else { idx }
          if i >= 0 && i < arr.length() {
            arr[i]
          } else {
            null
          }
        }
        _ => null
      }
    })
  }
}

///|
/// Evaluate array slicing
fn eval_slice_access(start : Int?, end : Int?, input : Json) -> Iter[Json] {
  match input {
    Array(arr) => {
      let len = arr.length()
      let s = match start {
        Some(n) => if n < 0 { len + n } else { n }
        None => 0
      }
      let e = match end {
        Some(n) => if n < 0 { len + n } else { n }
        None => len
      }
      let s_clamped = if s < 0 { 0 } else if s > len { len } else { s }
      let e_clamped = if e < 0 { 0 } else if e > len { len } else { e }
      let sliced = if s_clamped >= e_clamped {
        []
      } else {
        arr[s_clamped:e_clamped].to_array()
      }
      Iter::singleton(Json::array(sliced))
    }
    _ => Iter::singleton(null)
  }
}

///|
/// Evaluate optional expression, suppressing errors
fn eval_optional(inner : Expr, input : Json, env : Env) -> Iter[Json] {
  eval_with_env(inner, input, env) catch {
    _ => Iter::empty()
  }
}
