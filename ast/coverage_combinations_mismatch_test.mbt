///|
test "coverage: combinations empty and type mismatch" {
  json_inspect(coverage_eval("combinations", "[]"), content=[])
  assert_coverage_eval_error("combinations", "1")
}
