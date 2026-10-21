///|
test "coverage: range variants" {
  assert_reference_query("range(1; 4)", "null", "[1, 2, 3]", 0)
  assert_reference_query("range(0; 5; 2)", "null", "[0, 2, 4]", 0)
  assert_reference_query("range(5; 0; -2)", "null", "[5, 3, 1]", 0)
  assert_coverage_eval_error("range(\"a\"; 4)", "null")
}

///|
test "coverage: first/last with generator" {
  assert_reference_query("first(.[])", "[1, 2, 3]", "[1]", 0)
  assert_reference_query("last(.[])", "[1, 2, 3]", "[3]", 0)
  assert_reference_query("first(empty)", "null", "[]", 0)
  assert_reference_query("last(empty)", "null", "[null]", 0)
}

///|
test "coverage: any/all generator variants" {
  assert_reference_query("any(.[]; . > 2)", "[1, 3]", "[true]", 0)
  assert_reference_query("all(.[]; . > 2)", "[1, 3]", "[false]", 0)
  assert_reference_query("any(.[]; empty)", "[1, 3]", "[false]", 0)
  assert_reference_query("all(.[]; empty)", "[1, 3]", "[true]", 0)
}
