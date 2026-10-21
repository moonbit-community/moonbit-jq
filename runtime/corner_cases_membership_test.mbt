///|
/// Corner case tests for array search and membership

///|
test "corner: indices finds all occurrences" {
  assert_reference_query("indices(2)", "[1,2,3,2,1]", "[[1, 3]]", 0)
}

///|
test "corner: indices with no matches" {
  assert_reference_query("indices(99)", "[1,2,3]", "[[]]", 0)
}

///|
test "corner: inside checks array containment" {
  assert_reference_query("inside([1,2,3,4,5])", "[1,2]", "[true]", 0)
}

///|
test "corner: inside with non-subset" {
  assert_reference_query("inside([1,2,3])", "[1,2,4]", "[false]", 0)
}
