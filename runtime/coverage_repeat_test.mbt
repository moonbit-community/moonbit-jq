///|
test "coverage: repeat with limit and empty inner" {
  assert_reference_query("limit(5; repeat(1))", "null", "[1, 1, 1, 1, 1]", 0)
  assert_reference_query(
    "limit(5; repeat(empty, 1))", "null", "[1, 1, 1, 1, 1]", 0,
  )
}
