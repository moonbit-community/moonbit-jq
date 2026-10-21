///|
/// Corner case tests for array slicing

///|
test "corner: negative start index" {
  assert_reference_query(".[-2:]", "[1,2,3,4,5]", "[[4, 5]]", 0)
}

///|
test "corner: negative end index" {
  assert_reference_query(".[:-2]", "[1,2,3,4,5]", "[[1, 2, 3]]", 0)
}

///|
test "corner: negative range" {
  assert_reference_query(".[-3:-1]", "[1,2,3,4,5]", "[[3, 4]]", 0)
}

///|
test "corner: slice beyond bounds" {
  assert_reference_query(".[10:20]", "[1,2,3]", "[[]]", 0)
}

///|
test "corner: reverse slice" {
  assert_reference_query(".[3:1]", "[1,2,3,4,5]", "[[]]", 0)
}
