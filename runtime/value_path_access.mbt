///|
fn get_at_path(current : Json, path : ArrayView[Json]) -> Json? {
  match path {
    [] => Some(current)
    [key, .. rest] => {
      guard path_segment(key) is Some(segment) else { return None }
      guard segment.read(current) is Some(next) else { return None }
      get_at_path(next, rest)
    }
  }
}
