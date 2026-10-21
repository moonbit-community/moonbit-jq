///|
test "coverage: contains/inside/has on arrays and objects" {
  assert_reference_query("contains(2)", "[1, 2, 3]", "[]", 5)
  assert_reference_query("contains(\"a\")", "{\"a\": 1}", "[]", 5)
  assert_reference_query("\"a\" | inside({\"a\": 1})", "null", "[]", 5)
  assert_reference_query("[1, 2] | inside([2, 1, 3])", "null", "[true]", 0)
  assert_reference_query("[1, 9] | inside([2, 1, 3])", "null", "[false]", 0)
  assert_reference_query("has(\"1\")", "[10, 20]", "[]", 5)
  assert_reference_query("has(\"-1\")", "[10, 20]", "[]", 5)
  assert_reference_query("has(\"2\")", "[10, 20]", "[]", 5)
  assert_reference_query("has(\"x\")", "[10, 20]", "[]", 5)
}
