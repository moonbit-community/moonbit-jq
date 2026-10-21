///|
/// Corner case tests for any/all predicates

///|
test "corner: any with mixed booleans" {
  assert_reference_query("any", "[true,false,true]", "[true]", 0)
}

///|
test "corner: any with all false" {
  assert_reference_query("any", "[false,false,false]", "[false]", 0)
}

///|
test "corner: all with all true" {
  assert_reference_query("all", "[true,true,true]", "[true]", 0)
}

///|
test "corner: all with one false" {
  assert_reference_query("all", "[true,false,true]", "[false]", 0)
}

///|
test "corner: any with empty array" {
  assert_reference_query("any", "[]", "[false]", 0)
}

///|
test "corner: all with empty array" {
  assert_reference_query("all", "[]", "[true]", 0)
}

///|
test "corner: any with generator and condition" {
  assert_reference_query("any(1,2,3,4; . > 3)", "null", "[true]", 0)
}

///|
test "corner: all with generator and condition" {
  assert_reference_query("all(1,2,3,4; . > 0)", "null", "[true]", 0)
}
