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
    Array(arr) => {
      let len = arr.length()
      for i in 0..<len {
        let new_path = path.copy()
        new_path.push(i.to_string())
        collect_paths_with_filter(arr[i], new_path, filter_expr, env, results)
      }
    }
    _ => ()
  }
}

///|
/// Evaluate Paths
fn eval_paths(input : Json) -> Iter[Json] {
  let paths_list : Array[Json] = []
  fn collect_paths(value : Json, path : Array[Json]) {
    match value {
      Object(obj) =>
        for key, val in obj {
          let new_path = path + [Json::string(key)]
          paths_list.push(Json::array(new_path))
          collect_paths(val, new_path)
        }
      Array(arr) => {
        let len = arr.length()
        for i in 0..<len {
          let new_path = path + [Json::number(i.to_double())]
          paths_list.push(Json::array(new_path))
          collect_paths(arr[i], new_path)
        }
      }
      _ => ()
    }
  }

  collect_paths(input, [])
  paths_list.iter()
}

///|
/// Evaluate LeafPaths
fn eval_leaf_paths(input : Json) -> Iter[Json] {
  let paths_list : Array[Json] = []
  fn collect_leaf_paths(value : Json, path : Array[Json]) {
    match value {
      Object(obj) =>
        if obj.is_empty() {
          paths_list.push(Json::array(path))
        } else {
          for key, val in obj {
            collect_leaf_paths(val, path + [Json::string(key)])
          }
        }
      Array(arr) =>
        if arr.is_empty() {
          paths_list.push(Json::array(path))
        } else {
          let len = arr.length()
          for i in 0..<len {
            collect_leaf_paths(arr[i], path + [Json::number(i.to_double())])
          }
        }
      _ => paths_list.push(Json::array(path))
    }
  }

  collect_leaf_paths(input, [])
  paths_list.iter()
}

///|
/// Evaluate PathsWithFilter
fn eval_paths_with_filter(
  filter_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  let results : Array[Array[String]] = []
  collect_paths_with_filter(input, [], filter_expr, env, results)
  results.iter().map(path => Json::array(path.map(Json::string)))
}
