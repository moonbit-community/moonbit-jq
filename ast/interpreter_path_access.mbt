///|
/// Evaluate GetPath
fn eval_get_path(
  path_expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  let path_results = eval_with_env(path_expr, input, env).collect()
  if path_results.is_empty() {
    return Iterator::singleton(null)
  }
  match path_results[0] {
    Array(path_arr) => {
      let mut current = input
      for segment in path_arr {
        match (current, segment) {
          (Object(obj), String(key)) =>
            match obj.get(key) {
              Some(v) => current = v
              None => return Iterator::singleton(null)
            }
          (Array(arr), Number(idx, ..)) => {
            let i = idx.to_int()
            if i >= 0 && i < arr.length() {
              current = arr[i]
            } else {
              return Iterator::singleton(null)
            }
          }
          _ => return Iterator::singleton(null)
        }
      }
      Iterator::singleton(current)
    }
    _ => Iterator::singleton(null)
  }
}

///|
/// Evaluate Path (placeholder)
fn eval_path(_expr : Expr) -> Iterator[Json] {
  Iterator::singleton(Json::array([]))
}
