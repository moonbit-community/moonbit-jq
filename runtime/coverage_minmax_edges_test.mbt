///|
test "coverage: min_by/max_by empty and invalid key" {
  assert_reference_query("min_by(.)", "[]", "[null]", 0)
  assert_reference_query("max_by(.)", "[]", "[null]", 0)
  // Key expression yields empty => null.
  assert_reference_query("min_by(empty)", "[1, 2]", "[1]", 0)
  assert_reference_query("max_by(empty)", "[1, 2]", "[2]", 0)
  assert_coverage_eval_error("min_by(.)", "1")
  assert_coverage_eval_error("max_by(.)", "1")
}
