///|
/// Largest array index `setpath` will grow an array to (jq's limit).
const MAX_SETPATH_INDEX : Int32 = 536870911

///|
/// Helper to set value at a path in JSON structure.
///
/// Like jq, missing structure is created: a `null` becomes an object for a
/// string segment or an array for a number segment, and arrays are padded
/// with `null` up to the index being set. Negative indices count from the
/// end. Other type mismatches leave the value unchanged.
fn set_at_path(
  root : Json,
  path : ArrayView[Json],
  value : Json,
) -> Json raise PrimitiveError {
  match path {
    [] => value
    [segment, .. rest] =>
      match (root, segment) {
        (Object(_) | Null, String(key)) => {
          let new_obj = match root {
            Object(obj) => obj.copy()
            _ => Map([])
          }
          let current = new_obj.get(key).unwrap_or(null)
          new_obj[key] = set_at_path(current, rest, value)
          Json::object(new_obj)
        }
        (Array(_) | Null, Number(idx, ..)) => {
          let new_arr = match root {
            Array(arr) => arr.copy()
            _ => []
          }
          let raw = idx.to_int()
          let i = if raw < 0 { raw + new_arr.length() } else { raw }
          if i < 0 {
            raise InvalidOperation("Out of bounds negative array index")
          }
          if i > MAX_SETPATH_INDEX {
            raise InvalidOperation("Array index too large")
          }
          while new_arr.length() <= i {
            new_arr.push(null)
          }
          new_arr[i] = set_at_path(new_arr[i], rest, value)
          Json::array(new_arr)
        }
        (Array(arr), Object(bounds)) if bounds.contains("start") &&
          bounds.contains("end") => {
          let (start, end) = slice_segment(bounds)
          let (first, last) = slice_bounds(start, end, arr.length())
          let replacement = set_at_path(
            Json::array(arr[first:last].to_owned()),
            rest,
            value,
          )
          guard replacement is Array(values) else {
            raise InvalidOperation("A slice can only be assigned an array")
          }
          Json::array(arr[:first].to_owned() + values + arr[last:].to_owned())
        }
        _ => root
      }
  }
}

///|
/// Delete several paths at once, as jq's `delpaths` does: every path
/// addresses the original value, so deleting an array element does not
/// shift the others, a path listed twice deletes its element once, and
/// deleting a container also covers deletions inside it
/// (`[1,2,3] | delpaths([[0],[0]])` is `[2,3]`). Deleting `[]` gives null.
/// Negative array indices count from the end; segments of the wrong type
/// or out of range are ignored.
fn delete_paths(root : Json, paths : ArrayView[ArrayView[Json]]) -> Json {
  if paths.is_empty() {
    return root
  }
  if paths.iter().any(p => p.is_empty()) {
    return null
  }
  match root {
    Object(obj) => {
      let removed : Map[String, Bool] = Map([])
      let nested : Map[String, Array[ArrayView[Json]]] = Map([])
      for p in paths {
        guard p[0] is String(key) && obj.contains(key) else { continue }
        if p.length() == 1 {
          removed[key] = true
        } else {
          match nested.get(key) {
            Some(subs) => subs.push(p[1:])
            None => nested[key] = [p[1:]]
          }
        }
      }
      let out = obj.copy()
      for key, subs in nested {
        if !removed.contains(key) {
          out[key] = delete_paths(obj.get(key).unwrap_or(null), subs)
        }
      }
      for key, _ in removed {
        out.remove(key)
      }
      Json::object(out)
    }
    Array(arr) => {
      let removed : Map[Int32, Bool] = Map([])
      let nested : Map[Int32, Array[ArrayView[Json]]] = Map([])
      for p in paths {
        if p[0] is Object(bounds) &&
          bounds.contains("start") &&
          bounds.contains("end") &&
          p.length() == 1 {
          let (start, end) = slice_segment(bounds)
          let (first, last) = slice_bounds(start, end, arr.length())
          for i in first..<last {
            removed[i] = true
          }
          continue
        }
        guard p[0] is Number(idx, ..) else { continue }
        // Negative indices count from the end, so `[-1]` and `[len - 1]`
        // address the same element.
        let i = normalize_index(idx.to_int(), arr.length())
        guard i >= 0 && i < arr.length() else { continue }
        if p.length() == 1 {
          removed[i] = true
        } else {
          match nested.get(i) {
            Some(subs) => subs.push(p[1:])
            None => nested[i] = [p[1:]]
          }
        }
      }
      let out : Array[Json] = []
      for i, v in arr {
        if removed.contains(i) {
          continue
        }
        out.push(
          match nested.get(i) {
            Some(subs) => delete_paths(v, subs)
            None => v
          },
        )
      }
      Json::array(out)
    }
    _ => root
  }
}
