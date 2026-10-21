///|
/// Corner case tests for combinations

///|
test "corner: combinations of two arrays" {
  assert_reference_query(
    "[[1,2],[3,4]] | combinations", "null", "[[1, 3], [1, 4], [2, 3], [2, 4]]", 0,
  )
}

///|
test "corner: combinations with empty array" {
  assert_reference_query("[[], [1,2]] | combinations", "null", "[]", 0)
}

///|
test "corner: combinations of three arrays" {
  assert_reference_query(
    "[[1,2],[3],[4,5]] | combinations", "null", "[[1, 3, 4], [1, 3, 5], [2, 3, 4], [2, 3, 5]]",
    0,
  )
}
