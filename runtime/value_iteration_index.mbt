///|
fn indices_of_string(s : String, substr : String) -> Array[Json] {
  let result : Array[Json] = []
  let slen = s.length()
  let substr_len = substr.length()
  guard substr_len > 0 else { return result }
  let mut pos = 0
  while pos <= slen - substr_len {
    let slice = s[pos:].to_owned()
    match slice.find(substr) {
      Some(idx) => {
        let actual_idx = pos + idx
        result.push(Json::number(actual_idx.to_double()))
        pos = actual_idx + 1 // Advance by 1 to find overlapping matches
      }
      None => break
    }
  }
  result
}
