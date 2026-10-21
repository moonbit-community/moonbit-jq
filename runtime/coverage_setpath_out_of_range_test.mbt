///|
test "coverage: setpath out-of-range pads the array with nulls" {
  assert_reference_query("setpath([3]; 1)", "[0]", "[[0, null, null, 1]]", 0)
  assert_reference_query("setpath([-1]; 1)", "[0, 5]", "[[0, 1]]", 0)
  assert_coverage_eval_error("setpath([-3]; 1)", "[0, 5]")
  assert_coverage_eval_error("setpath([1e300]; 1)", "[0]")
}
