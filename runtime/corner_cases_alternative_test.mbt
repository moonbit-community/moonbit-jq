///|
/// Corner case tests for null coalescing and defaults

///|
test "corner: multiple alternatives" {
  assert_reference_query(".a // .b // .c // \"default\"", "{\"c\":5}", "[5]", 0)
}

///|
test "corner: alternative with false" {
  assert_reference_query(". // \"default\"", "false", "[\"default\"]", 0)
}

///|
test "corner: alternative with 0" {
  assert_reference_query(". // \"default\"", "0", "[0]", 0)
}

///|
test "corner: alternative with empty string" {
  assert_reference_query(". // \"default\"", "\"\"", "[\"\"]", 0)
}
