///|
test "coverage: arithmetic array subtraction and string repetition" {
  assert_reference_query("[1,2,3] - [2]", "null", "[[1, 3]]", 0)
  assert_reference_query("\"ab\" * 3", "null", "[\"ababab\"]", 0)
  assert_reference_query("3 * \"ab\"", "null", "[\"ababab\"]", 0)
}
