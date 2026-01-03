///|
/// Helper to set value at a path in JSON structure
fn set_at_path(root : Json, path : Array[Json], value : Json) -> Json {
  if path.is_empty() {
    return value
  }
  let segment = path[0]
  let remaining = path[1:]
  match (root, segment) {
    (Object(obj), String(key)) => {
      let new_obj = Map::from_array(obj.iterator().collect())
      if remaining.length() == 0 {
        new_obj[key] = value
      } else {
        let current = obj.get(key).unwrap_or(null)
        new_obj[key] = set_at_path(current, remaining.to_array(), value)
      }
      Json::object(new_obj)
    }
    (Array(arr), Number(idx, ..)) => {
      let i = idx.to_int()
      if i >= 0 && i < arr.length() {
        let new_arr = arr.copy()
        if remaining.length() == 0 {
          new_arr[i] = value
        } else {
          new_arr[i] = set_at_path(arr[i], remaining.to_array(), value)
        }
        Json::array(new_arr)
      } else {
        root
      }
    }
    _ => root
  }
}

///|
/// Helper to delete value at a path in JSON structure
fn delete_at_path(root : Json, path : Array[Json]) -> Json {
  if path.is_empty() {
    return null
  }
  if path.length() == 1 {
    let segment = path[0]
    match (root, segment) {
      (Object(obj), String(key)) => {
        let new_obj = Map::from_array(obj.iterator().collect())
        new_obj.remove(key)
        Json::object(new_obj)
      }
      (Array(arr), Number(idx, ..)) => {
        let i = idx.to_int()
        if i >= 0 && i < arr.length() {
          let new_arr : Array[Json] = []
          for j = 0; j < arr.length(); j = j + 1 {
            if j != i {
              new_arr.push(arr[j])
            }
          }
          Json::array(new_arr)
        } else {
          root
        }
      }
      _ => root
    }
  } else {
    let segment = path[0]
    let remaining = path[1:]
    match (root, segment) {
      (Object(obj), String(key)) => {
        let new_obj = Map::from_array(obj.iterator().collect())
        match obj.get(key) {
          Some(current) =>
            new_obj[key] = delete_at_path(current, remaining.to_array())
          None => ()
        }
        Json::object(new_obj)
      }
      (Array(arr), Number(idx, ..)) => {
        let i = idx.to_int()
        if i >= 0 && i < arr.length() {
          let new_arr = arr.copy()
          new_arr[i] = delete_at_path(arr[i], remaining.to_array())
          Json::array(new_arr)
        } else {
          root
        }
      }
      _ => root
    }
  }
}

///|
/// Evaluate SetPath
fn eval_set_path(
  path_expr : Expr,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  let path_results = eval_with_env(path_expr, input, env).collect()
  let value_results = eval_with_env(value_expr, input, env).collect()
  if path_results.is_empty() || value_results.is_empty() {
    return Iterator::singleton(input)
  }
  match path_results[0] {
    Array(path_arr) =>
      if path_arr.is_empty() {
        Iterator::singleton(value_results[0])
      } else {
        Iterator::singleton(set_at_path(input, path_arr, value_results[0]))
      }
    _ => Iterator::singleton(input)
  }
}

///|
/// Evaluate DelPaths
fn eval_del_paths(
  paths_expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  let paths_results = eval_with_env(paths_expr, input, env).collect()
  if paths_results.is_empty() {
    return Iterator::singleton(input)
  }
  match paths_results[0] {
    Array(paths_arr) => {
      let mut result = input
      for path_json in paths_arr {
        match path_json {
          Array(path) => result = delete_at_path(result, path)
          _ => ()
        }
      }
      Iterator::singleton(result)
    }
    _ => Iterator::singleton(input)
  }
}
