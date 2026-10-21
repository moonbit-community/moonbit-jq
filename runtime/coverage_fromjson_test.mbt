///|
test "coverage: fromjson parses and errors" {
  json_inspect(coverage_eval("fromjson", "\"{\\\"a\\\": 1}\""), content=[
    { "a": 1 },
  ])
  assert_coverage_eval_error("fromjson", "\"{\"")
  assert_coverage_eval_error("fromjson", "1")
}
