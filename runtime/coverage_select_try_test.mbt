///|
test "coverage: select(empty) yields no outputs" {
  assert_reference_query(".[] | select(empty)", "[1, 2, 3]", "[]", 0)
}

///|
test "coverage: try-catch executes catch branch" {
  assert_reference_query("try (1 / 0) catch 42", "null", "[42]", 0)
}
