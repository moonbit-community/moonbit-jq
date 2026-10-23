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
    [key, .. rest] => {
      guard path_segment(key) is Some(segment) else { return root }
      guard segment.read(root) is Some(current) else { return root }
      segment.write(root, set_at_path(current, rest, value))
    }
  }
}

///|
/// Sort and group raw path prefixes as jq does. Child edits are spliced back
/// before deleting this level's keys; overlapping slices can therefore change
/// the positions addressed by a later group.
fn delete_paths(
  root : Json,
  paths : ArrayView[ArrayView[Json]],
) -> Json raise PrimitiveError {
  if paths.is_empty() {
    return root
  }
  let sorted = paths.to_owned()
  sorted.sort_by(compare_array_view)
  if sorted[0].is_empty() {
    return null
  }
  delete_paths_sorted(root, sorted, 0)
}

///|
fn delete_paths_sorted(
  root : Json,
  paths : ArrayView[ArrayView[Json]],
  depth : Int32,
) -> Json raise PrimitiveError {
  let mut updated = root
  let removed : Array[PathSegment] = []
  for i = 0; i < paths.length(); {
    let key = paths[i][depth]
    let mut end = i + 1
    while end < paths.length() && paths[end][depth] == key {
      end += 1
    }
    if path_segment(key) is Some(segment) {
      if paths[i].length() == depth + 1 {
        removed.push(segment)
      } else if segment.read(updated) is Some(current) && !(current is Null) {
        let next = delete_paths_sorted(current, paths[i:end], depth + 1)
        updated = segment.write(updated, next)
      }
    }
    continue end
  }
  delete_segments(updated, removed)
}

///|
/// Delete sibling targets simultaneously, normalizing indices and slice bounds
/// against the container after all child edits have been applied.
fn delete_segments(root : Json, segments : Array[PathSegment]) -> Json {
  match root {
    Object(obj) => {
      let out = obj.copy()
      for segment in segments {
        if segment is Field(key) {
          out.remove(key)
        }
      }
      Json::object(out)
    }
    Array(arr) => {
      let removed : Map[Int32, Bool] = Map([])
      for segment in segments {
        match segment {
          Element(i) => removed[normalize_index(i, arr.length())] = true
          Region(start, end) => {
            let (first, last) = slice_bounds(start, end, arr.length())
            for i in first..<last {
              removed[i] = true
            }
          }
          Field(_) => ()
        }
      }
      let out : Array[Json] = []
      for i, v in arr {
        if !removed.contains(i) {
          out.push(v)
        }
      }
      Json::array(out)
    }
    _ => root
  }
}
