///|
/// Corner case tests for empty outputs and error handling

///|
test "corner: empty produces no output" {
  assert_reference_query("empty", "42", "[]", 0)
}

///|
test "corner: empty in array construction" {
  assert_reference_query("[1, empty, 2]", "null", "[[1, 2]]", 0)
}

///|
test "corner: multiple values with comma" {
  assert_reference_query("1, 2, 3", "null", "[1, 2, 3]", 0)
}

///|
test "corner: empty array iteration" {
  assert_reference_query("[.[] | . * 2]", "[]", "[[]]", 0)
}
