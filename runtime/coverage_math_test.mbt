///|
test "coverage: math functions" {
  json_inspect(coverage_eval("pow(3)", "2"), content=[8])
  assert_reference_query("log", "1", "[0]", 0)
  assert_reference_query("exp", "0", "[1]", 0)
  assert_reference_query("sin", "0", "[0]", 0)
  assert_reference_query("cos", "0", "[1]", 0)
  assert_reference_query("tan", "0", "[0]", 0)
  assert_reference_query("asin", "0", "[0]", 0)
  assert_reference_query("acos", "1", "[0]", 0)
  assert_reference_query("atan", "0", "[0]", 0)
  assert_coverage_eval_error("sin", "\"x\"")
}
