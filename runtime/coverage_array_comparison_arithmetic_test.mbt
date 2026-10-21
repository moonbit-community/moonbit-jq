///|
test "coverage: array comparisons exercise element and length ordering" {
  assert_reference_query("[1] < [1, 2]", "null", "[true]", 0)
  assert_reference_query("[1, 0] < [1, 2]", "null", "[true]", 0)
}

///|
test "coverage: invalid arithmetic operations error" {
  assert_coverage_eval_error("1 + []", "null")
  assert_coverage_eval_error("1 - \"x\"", "null")
  assert_coverage_eval_error("1 * {}", "null")
  assert_coverage_eval_error("1 / []", "null")
}
