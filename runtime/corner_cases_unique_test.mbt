///|
/// Corner case tests for unique and unique_by

///|
test "corner: unique_by with single attribute" {
  assert_reference_query(
    "unique_by(.a)", "[{\"a\":1,\"b\":2},{\"a\":1,\"b\":3},{\"a\":2,\"b\":1}]", "[[{\"a\": 1, \"b\": 2}, {\"a\": 2, \"b\": 1}]]",
    0,
  )
}

///|
test "corner: unique_by with empty array" {
  assert_reference_query("unique_by(.x)", "[]", "[[]]", 0)
}

///|
test "corner: unique with duplicates" {
  assert_reference_query("unique", "[1,2,1,3,2,4]", "[[1, 2, 3, 4]]", 0)
}
