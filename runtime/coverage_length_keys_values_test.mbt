///|
test "coverage: length/keys/values coverage and mismatches" {
  assert_reference_query("length", "{\"a\": 1, \"b\": 2}", "[2]", 0)
  assert_reference_query("length", "null", "[0]", 0)
  assert_coverage_eval_error("length", "true")
  assert_reference_query("keys", "[10, 20]", "[[0, 1]]", 0)
  assert_reference_query(
    "values", "{\"a\": 1, \"b\": 2}", "[{\"a\": 1, \"b\": 2}]", 0,
  )
  assert_reference_query("values", "true", "[true]", 0)
  assert_coverage_eval_error("keys", "true")
}
