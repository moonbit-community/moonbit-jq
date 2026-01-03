///|
fn collect_paths_with_filter(
  value : Json,
  path : Array[String],
  filter_expr : Expr,
  env : Env,
  results : Array[Array[String]],
) -> Unit raise InterpreterError {
  let filter_results = eval_with_env(filter_expr, value, env) catch {
    _ => return
  }
  let filter_results_arr = filter_results.collect()
  if not(filter_results_arr.is_empty()) {
    match filter_results_arr[0] {
      True => if not(path.is_empty()) { results.push(path.copy()) }
      _ => ()
    }
  }
  match value {
    Object(obj) =>
      for key, val in obj {
        let new_path = path.copy()
        new_path.push(key)
        collect_paths_with_filter(val, new_path, filter_expr, env, results)
      }
    Array(arr) =>
      for i = 0; i < arr.length(); i = i + 1 {
        let new_path = path.copy()
        new_path.push(i.to_string())
        collect_paths_with_filter(arr[i], new_path, filter_expr, env, results)
      }
    _ => ()
  }
}

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
