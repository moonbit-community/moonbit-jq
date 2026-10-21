///|
/// Corner case tests for min/max

///|
test "corner: min_by with empty array returns null" {
  assert_reference_query("min_by(.x)", "[]", "[null]", 0)
}

///|
test "corner: max_by with empty array returns null" {
  assert_reference_query("max_by(.x)", "[]", "[null]", 0)
}

///|
test "corner: min_by with single element" {
  assert_reference_query("min_by(.x)", "[{\"x\":5}]", "[{\"x\": 5}]", 0)
}

///|
test "corner: max_by with single element" {
  assert_reference_query("max_by(.x)", "[{\"x\":5}]", "[{\"x\": 5}]", 0)
}
