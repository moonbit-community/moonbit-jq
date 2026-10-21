///|
test "coverage: fromjson parses and errors" {
  assert_reference_query("fromjson", "\"{\\\"a\\\": 1}\"", "[{\"a\": 1}]", 0)
  assert_coverage_eval_error("fromjson", "\"{\"")
  assert_coverage_eval_error("fromjson", "1")
}
