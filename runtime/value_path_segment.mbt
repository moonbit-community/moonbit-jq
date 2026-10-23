///|
/// Navigation and mutation share these decoded segments. Provenance retains
/// the original JSON keys, including unnormalized slice bounds, for `path()`.
priv enum PathSegment {
  Field(String)
  Element(Int32)
  Region(Int32?, Int32?)
}

///|
fn path_segment(key : Json) -> PathSegment? {
  match key {
    String(name) => Some(Field(name))
    Number(n, ..) => Some(Element(n.to_int()))
    Object(bounds) if bounds.contains("start") && bounds.contains("end") => {
      let (start, end) = slice_segment(bounds)
      Some(Region(start, end))
    }
    _ => None
  }
}

///|
fn slice_key(start : Int32?, end : Int32?) -> Json {
  {
    "start": start.map(n => Json::number(n.to_double())).unwrap_or(null),
    "end": end.map(n => Json::number(n.to_double())).unwrap_or(null),
  }
}

///|
/// `None` means an incompatible container; missing entries read as null.
fn PathSegment::read(self : PathSegment, root : Json) -> Json? {
  match (self, root) {
    (_, Null) => Some(null)
    (Field(key), Object(obj)) => Some(obj.get(key).unwrap_or(null))
    (Element(i), Array(arr)) =>
      Some(arr.get(normalize_index(i, arr.length())).unwrap_or(null))
    (Region(start, end), Array(_) | String(_)) =>
      Some(slice_value(root, start, end))
    _ => None
  }
}

///|
fn PathSegment::write(
  self : PathSegment,
  root : Json,
  replacement : Json,
) -> Json raise PrimitiveError {
  match (self, root) {
    (Field(key), Object(_) | Null) => {
      let obj = match root {
        Object(obj) => obj.copy()
        _ => Map([])
      }
      obj[key] = replacement
      Json::object(obj)
    }
    (Element(raw), Array(_) | Null) => {
      let arr = match root {
        Array(arr) => arr.copy()
        _ => []
      }
      let i = normalize_index(raw, arr.length())
      if i < 0 {
        raise InvalidOperation("Out of bounds negative array index")
      }
      if i > MAX_SETPATH_INDEX {
        raise InvalidOperation("Array index too large")
      }
      while arr.length() <= i {
        arr.push(null)
      }
      arr[i] = replacement
      Json::array(arr)
    }
    (Region(start, end), Array(_) | Null) => {
      let arr = match root {
        Array(arr) => arr
        _ => []
      }
      let (first, last) = slice_bounds(start, end, arr.length())
      guard replacement is Array(values) else {
        raise InvalidOperation("A slice can only be assigned an array")
      }
      Json::array(arr[:first].to_owned() + values + arr[last:].to_owned())
    }
    _ => root
  }
}
