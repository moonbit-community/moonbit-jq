///|
/// Corner case tests for has/in membership

///|
test "corner: has() with existing key" {
  assert_reference_query("has(\"a\")", "{\"a\":1}", "[true]", 0)
}

///|
test "corner: has() with missing key" {
  assert_reference_query("has(\"b\")", "{\"a\":1}", "[false]", 0)
}

///|
test "corner: has() with array index" {
  assert_reference_query("has(0)", "[1,2,3]", "[true]", 0)
}

///|
test "corner: has() with out of bounds index" {
  assert_reference_query("has(10)", "[1,2,3]", "[false]", 0)
}

///|
test "corner: in() check key in object" {
  assert_reference_query("in({\"a\":1,\"b\":2})", "\"a\"", "[true]", 0)
}

///|
test "corner: in() check missing key" {
  assert_reference_query("in({\"a\":1,\"b\":2})", "\"c\"", "[false]", 0)
}
