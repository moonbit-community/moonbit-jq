///|
/// Return whether a JSON value is truthy according to jq semantics.
///
/// jq treats only `false` and `null` as falsy. Numbers, strings, arrays, and
/// objects are truthy even when they are zero or empty, so this helper should be
/// used for conditionals and logical operators instead of language-level
/// truthiness rules.
pub fn is_truthy(value : Json) -> Bool {
  match value {
    False | Null => false
    _ => true
  }
}
