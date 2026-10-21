///|
test "coverage: sort_by empty key uses null" {
  assert_reference_query("sort_by(empty)", "[2]", "[[2]]", 0)
}

///|
test "coverage: group_by empty key uses null" {
  assert_reference_query("group_by(empty)", "[1, 2]", "[[[1, 2]]]", 0)
}
