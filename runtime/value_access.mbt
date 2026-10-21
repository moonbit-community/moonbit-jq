///|
fn normalize_index(idx : Int32, len : Int32) -> Int32 {
  if idx < 0 {
    len + idx
  } else {
    idx
  }
}

///|
fn clamp_index(value : Int32, len : Int32) -> Int32 {
  if value < 0 {
    0
  } else if value > len {
    len
  } else {
    value
  }
}

///|
fn slice_bounds(start : Int32?, end : Int32?, len : Int32) -> (Int32, Int32) {
  let first = clamp_index(
    start.map(n => normalize_index(n, len)).unwrap_or(0),
    len,
  )
  let last = clamp_index(
    end.map(n => normalize_index(n, len)).unwrap_or(len),
    len,
  ).max(first)
  (first, last)
}

///|
fn slice_value(input : Json, start : Int32?, end : Int32?) -> Json {
  match input {
    Array(arr) => {
      let (first, last) = slice_bounds(start, end, arr.length())
      Json::array(arr[first:last].to_owned())
    }
    String(s) => {
      let (first, last) = slice_bounds(start, end, s.char_length())
      let out = StringBuilder()
      for (i, c) in s.iter().mapi((i, c) => (i, c)) {
        if i >= first && i < last {
          out.write_char(c)
        }
      }
      Json::string(out.to_string())
    }
    _ => null
  }
}

///|
fn slice_segment(segment : Map[String, Json]) -> (Int32?, Int32?) {
  fn bound(v : Json?) -> Int32? {
    match v {
      Some(Number(n, ..)) => Some(n.to_int())
      _ => None
    }
  }
  (bound(segment.get("start")), bound(segment.get("end")))
}
