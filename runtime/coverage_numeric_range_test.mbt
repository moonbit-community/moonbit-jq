///|
test "coverage: numeric builtins mismatches" {
  assert_coverage_eval_error("round", "\"x\"")
  assert_coverage_eval_error("ceil", "\"x\"")
  assert_coverage_eval_error("abs", "\"x\"")
}

///|
test "coverage: math and range edges" {
  assert_reference_query("pow(.; empty)", "2", "[]", 0)
  assert_coverage_eval_error("pow(2)", "\"x\"")
  assert_coverage_eval_error("log", "\"x\"")
  assert_coverage_eval_error("exp", "\"x\"")
  assert_coverage_eval_error("sin", "\"x\"")
  assert_coverage_eval_error("cos", "\"x\"")
  assert_coverage_eval_error("tan", "\"x\"")
  assert_coverage_eval_error("asin", "\"x\"")
  assert_coverage_eval_error("acos", "\"x\"")
  assert_coverage_eval_error("atan", "\"x\"")
  assert_reference_query("range(empty; 3)", "null", "[]", 0)
  assert_reference_query("range(1; 3; empty)", "null", "[]", 0)
  assert_coverage_eval_error("range(1; \"x\")", "null")
}
