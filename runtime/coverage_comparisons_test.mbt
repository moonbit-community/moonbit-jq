///|
test "coverage: null/bool comparisons" {
  assert_reference_query("null < null", "null", "[false]", 0)
  assert_reference_query("null < false", "null", "[true]", 0)
  assert_reference_query("false < true", "null", "[true]", 0)
  assert_reference_query("true > false", "null", "[true]", 0)
}
