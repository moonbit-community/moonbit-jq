///|
test "coverage: numeric builtins mismatches" {
  assert_coverage_eval_error("round", "\"x\"")
  assert_coverage_eval_error("ceil", "\"x\"")
  assert_coverage_eval_error("abs", "\"x\"")
}

///|
test "coverage: math and range edges" {
  json_inspect(coverage_eval("pow(empty)", "2"), content=[null])
  assert_coverage_eval_error("pow(2)", "\"x\"")
  assert_coverage_eval_error("log", "\"x\"")
  assert_coverage_eval_error("exp", "\"x\"")
  assert_coverage_eval_error("sin", "\"x\"")
  assert_coverage_eval_error("cos", "\"x\"")
  assert_coverage_eval_error("tan", "\"x\"")
  assert_coverage_eval_error("asin", "\"x\"")
  assert_coverage_eval_error("acos", "\"x\"")
  assert_coverage_eval_error("atan", "\"x\"")
  json_inspect(coverage_eval("range(empty; 3)", "null"), content=[])
  json_inspect(coverage_eval("range(1; 3; empty)", "null"), content=[])
  assert_coverage_eval_error("range(1; \"x\")", "null")
}
