///|
test "coverage: numeric builtins type mismatches" {
  assert_coverage_eval_error("floor", "\"x\"")
  assert_coverage_eval_error("sqrt", "\"x\"")
}

///|
test "coverage: add ignores non-numbers" {
  json_inspect(coverage_eval("add", "[1, \"x\", 2]"), content=[3])
}
