///|
pub fn is_truthy(value : Json) -> Bool {
  match value {
    False | Null => false
    _ => true
  }
}
