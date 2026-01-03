///|
/// Determine jq truthiness (false/null are falsey, everything else is truthy)
fn is_truthy(value : Json) -> Bool {
  match value {
    False | Null => false
    _ => true
  }
}
