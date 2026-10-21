///|
/// Corner case tests for getpath

///|
test "corner: getpath returns null for non-existent path" {
  assert_reference_query(
    "getpath([\"x\",\"y\",\"z\"])", "{\"a\":1}", "[null]", 0,
  )
}

///|
test "corner: getpath with empty path returns input" {
  assert_reference_query("getpath([])", "{\"a\":1}", "[{\"a\": 1}]", 0)
}
