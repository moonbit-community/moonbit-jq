///|
/// Corner case tests for limit edge cases

///|
test "corner: limit with zero" {
  assert_reference_query("limit(0; 1,2,3)", "null", "[]", 0)
}

///|
test "corner: limit larger than available" {
  assert_reference_query("limit(10; 1,2,3)", "null", "[1, 2, 3]", 0)
}

///|
test "corner: limit with negative number" {
  assert_reference_query("limit(-1; 1,2,3)", "null", "[1, 2, 3]", 0)
}
