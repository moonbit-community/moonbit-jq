///|
priv enum PathFrame {
  ObjectFrame(Iter2[String, Json], Bool)
  ArrayFrame(Array[Json], Int, Int, Bool)
}

///|
fn path_index_number(i : Int) -> Json {
  Json::number(i.to_double())
}

///|
fn push_container_frame(
  stack : Array[PathFrame],
  value : Json,
  has_segment : Bool,
) -> Bool {
  match value {
    Object(obj) =>
      if obj.is_empty() {
        false
      } else {
        stack.push(ObjectFrame(obj.iter2(), has_segment))
        true
      }
    Array(arr) =>
      if arr.is_empty() {
        false
      } else {
        stack.push(ArrayFrame(arr, 0, arr.length(), has_segment))
        true
      }
    _ => false
  }
}

///|
/// Evaluate Paths
fn eval_paths(input : Json) -> Iter[Json] {
  iter_paths(input, false, path_index_number)
}

///|
/// Evaluate LeafPaths
fn eval_leaf_paths(input : Json) -> Iter[Json] {
  iter_paths(input, true, path_index_number)
}

///|
/// Evaluate PathsWithFilter, following jq 1.7's definition
/// `def paths(f): path(.. | select(f)) | select(length > 0);`: `f` runs on
/// every value (the root included), errors from it propagate, and the
/// root path itself is not produced.
fn eval_paths_with_filter(
  filter_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  path_values(Pipe(Recurse, Select(filter_expr)), input, env)
  .filter(pair => pair.0.length() > 0)
  .map(pair => Json::array(pair.0))
  .iter()
}

///|
fn iter_paths(
  input : Json,
  leaf_only : Bool,
  index_segment : (Int) -> Json,
) -> Iter[Json] {
  let path : Array[Json] = []
  let stack_ref : Ref[Array[PathFrame]] = Ref([])
  let root_pending : Ref[Bool] = Ref(true)
  Iter::new(fn() {
    if root_pending.val {
      root_pending.val = false
      let root_has_children = push_container_frame(stack_ref.val, input, false)
      if leaf_only && !root_has_children {
        return Some(Json::array(path.copy()))
      }
    }
    while true {
      match stack_ref.val.pop() {
        None => return None
        Some(frame) =>
          match frame {
            ObjectFrame(iter, has_segment) =>
              match iter.next() {
                Some((key, val)) => {
                  stack_ref.val.push(ObjectFrame(iter, has_segment))
                  path.push(Json::string(key))
                  let pushed = push_container_frame(stack_ref.val, val, true)
                  if leaf_only {
                    if pushed {
                      continue
                    }
                    let result = Json::array(path.copy())
                    ignore(path.pop())
                    return Some(result)
                  }
                  let result = Json::array(path.copy())
                  if !pushed {
                    ignore(path.pop())
                  }
                  return Some(result)
                }
                None => {
                  if has_segment {
                    ignore(path.pop())
                  }
                  continue
                }
              }
            ArrayFrame(arr, idx, len, has_segment) =>
              if idx >= len {
                if has_segment {
                  ignore(path.pop())
                }
                continue
              } else {
                let value = arr[idx]
                stack_ref.val.push(ArrayFrame(arr, idx + 1, len, has_segment))
                path.push(index_segment(idx))
                let pushed = push_container_frame(stack_ref.val, value, true)
                if leaf_only {
                  if pushed {
                    continue
                  }
                  let result = Json::array(path.copy())
                  ignore(path.pop())
                  return Some(result)
                }
                let result = Json::array(path.copy())
                if !pushed {
                  ignore(path.pop())
                }
                return Some(result)
              }
          }
      }
    } nobreak {
      None
    }
  })
}
