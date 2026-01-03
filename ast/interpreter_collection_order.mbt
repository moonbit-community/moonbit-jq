///|
/// Evaluate UniqueBy
fn eval_unique_by(
  expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  match input {
    Array(arr) => {
      let seen : Map[String, Bool] = {}
      let results : Array[Json] = []
      for elem in arr {
        let key_results = eval_with_env(expr, elem, env).collect()
        if not(key_results.is_empty()) {
          let key = key_results[0].to_string()
          if not(seen.contains(key)) {
            seen[key] = true
            results.push(elem)
          }
        }
      }
      Iterator::singleton(Json::array(results))
    }
    _ => raise TypeMismatch("array", json_type_name(input))
  }
}

///|
/// Evaluate MinBy
fn eval_min_by(
  expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  match input {
    Array(arr) =>
      if arr.is_empty() {
        Iterator::singleton(null)
      } else {
        let mut min_elem : Json = arr[0]
        let min_val_results = eval_with_env(expr, min_elem, env).collect()
        if min_val_results.is_empty() {
          return Iterator::singleton(null)
        }
        let mut min_val = min_val_results[0]
        for i = 1; i < arr.length(); i = i + 1 {
          let elem = arr[i]
          let val_results = eval_with_env(expr, elem, env).collect()
          if not(val_results.is_empty()) {
            let val = val_results[0]
            if compare_json(val, min_val) < 0 {
              min_val = val
              min_elem = elem
            }
          }
        }
        Iterator::singleton(min_elem)
      }
    _ => raise TypeMismatch("array", json_type_name(input))
  }
}

///|
/// Evaluate MaxBy
fn eval_max_by(
  expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  match input {
    Array(arr) =>
      if arr.is_empty() {
        Iterator::singleton(null)
      } else {
        let mut max_elem : Json = arr[0]
        let max_val_results = eval_with_env(expr, max_elem, env).collect()
        if max_val_results.is_empty() {
          return Iterator::singleton(null)
        }
        let mut max_val = max_val_results[0]
        for i = 1; i < arr.length(); i = i + 1 {
          let elem = arr[i]
          let val_results = eval_with_env(expr, elem, env).collect()
          if not(val_results.is_empty()) {
            let val = val_results[0]
            if compare_json(val, max_val) > 0 {
              max_val = val
              max_elem = elem
            }
          }
        }
        Iterator::singleton(max_elem)
      }
    _ => raise TypeMismatch("array", json_type_name(input))
  }
}
