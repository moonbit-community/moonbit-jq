///|
test "coverage: indices/index/rindex" {
  assert_reference_query("indices(2)", "[1, 2, 1, 2]", "[[1, 3]]", 0)
  assert_reference_query("index(2)", "[1, 2, 3]", "[1]", 0)
  assert_reference_query("index(9)", "[1, 2, 3]", "[null]", 0)
  assert_reference_query("rindex(\"o\")", "\"foobar\"", "[2]", 0)
}
