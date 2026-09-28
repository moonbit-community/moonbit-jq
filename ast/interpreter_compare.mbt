///|
/// Rank of a JSON value's type in jq's ordering:
/// null < false < true < numbers < strings < arrays < objects.
fn json_type_rank(v : Json) -> Int {
  match v {
    Null => 0
    False => 1
    True => 2
    Number(_) => 3
    String(_) => 4
    Array(_) => 5
    Object(_) => 6
  }
}

///|
/// Compare JSON values using jq's total order (used by comparisons, `==`,
/// sorting, `unique`, `min`/`max`, ...).
fn compare_json(a : Json, b : Json) -> Int {
  let rank_a = json_type_rank(a)
  let rank_b = json_type_rank(b)
  if rank_a != rank_b {
    return rank_a.compare(rank_b)
  }
  match (a, b) {
    (Number(x, ..), Number(y, ..)) => x.compare(y)
    (String(x), String(y)) => compare_code_points(x, y)
    (Array(x), Array(y)) => compare_array_view(x, y)
    (Object(x), Object(y)) => compare_objects(x, y)
    // Same rank and not a container, number or string: null/false/true.
    _ => 0
  }
}

///|
/// Compare strings lexicographically by Unicode code point, as jq does.
/// (MoonBit's `String::compare` orders by length first.)
fn compare_code_points(a : String, b : String) -> Int {
  let iter_a = a.iter()
  let iter_b = b.iter()
  while true {
    match (iter_a.next(), iter_b.next()) {
      (None, None) => return 0
      (None, Some(_)) => return -1
      (Some(_), None) => return 1
      (Some(x), Some(y)) => if x != y { return x.compare(y) }
    }
  }
  0
}

///|
fn sorted_object_keys(obj : Map[String, Json]) -> Array[String] {
  let keys = obj.keys().collect()
  keys.sort_by(compare_code_points)
  keys
}

///|
/// Objects compare first by their sorted key arrays, then value by value in
/// sorted key order.
fn compare_objects(x : Map[String, Json], y : Map[String, Json]) -> Int {
  let keys_x = sorted_object_keys(x)
  let keys_y = sorted_object_keys(y)
  let common = if keys_x.length() < keys_y.length() {
    keys_x.length()
  } else {
    keys_y.length()
  }
  for i in 0..<common {
    let cmp = compare_code_points(keys_x[i], keys_y[i])
    if cmp != 0 {
      return cmp
    }
  }
  let cmp = keys_x.length().compare(keys_y.length())
  if cmp != 0 {
    return cmp
  }
  for key in keys_x {
    let cmp = compare_json(
      x.get(key).unwrap_or(null),
      y.get(key).unwrap_or(null),
    )
    if cmp != 0 {
      return cmp
    }
  }
  0
}

///|
fn compare_array_view(a : ArrayView[Json], b : ArrayView[Json]) -> Int {
  match (a, b) {
    ([], []) => 0
    ([], _) => -1
    (_, []) => 1
    ([head_a, .. tail_a], [head_b, .. tail_b]) => {
      let cmp = compare_json(head_a, head_b)
      if cmp != 0 {
        cmp
      } else {
        compare_array_view(tail_a, tail_b)
      }
    }
  }
}
