///|
pub fn first_opt(results : Array[Json]) -> Json? {
  match results {
    [] => None
    [first, .. _] => Some(first)
  }
}

///|
pub fn first_or_null(results : Array[Json]) -> Json {
  match results {
    [] => null
    [first, .. _] => first
  }
}
