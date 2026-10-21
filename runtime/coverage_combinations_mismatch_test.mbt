///|
test "coverage: combinations empty and type mismatch" {
  assert_reference_query("combinations", "[]", "[[]]", 0)
  assert_coverage_eval_error("combinations", "1")
}
