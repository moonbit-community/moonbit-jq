///|
test "coverage: array builtins type mismatches" {
  assert_coverage_eval_error("sort", "1")
  assert_coverage_eval_error("reverse", "1")
  assert_coverage_eval_error("unique", "1")
  assert_coverage_eval_error("min", "1")
  assert_coverage_eval_error("max", "1")
}
