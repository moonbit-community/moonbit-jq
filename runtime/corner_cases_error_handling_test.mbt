///|
/// Corner case tests for error propagation

///|
test "corner: error in pipeline stops execution" {
  assert_reference_query(".x | . * 2", "{}", "[]", 5)
}

///|
test "corner: try catches errors" {
  assert_reference_query("try .x catch \"error\"", "{}", "[null]", 0)
}

///|
test "corner: try with successful operation" {
  assert_reference_query("try .x catch \"error\"", "{\"x\":42}", "[42]", 0)
}
