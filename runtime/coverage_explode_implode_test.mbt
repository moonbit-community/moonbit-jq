///|
test "coverage: explode/implode and type mismatches" {
  assert_reference_query("explode", "\"A\"", "[[65]]", 0)
  assert_reference_query("implode", "[65]", "[\"A\"]", 0)
  // Invalid code point is ignored.
  json_inspect(coverage_eval("implode", "[1114112]"), content=[""])
  assert_coverage_eval_error("explode", "1")
  assert_coverage_eval_error("implode", "\"x\"")
}
