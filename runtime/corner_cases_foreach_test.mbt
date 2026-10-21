///|
/// Corner case tests for foreach

///|
test "corner: foreach accumulating values" {
  assert_reference_query(
    "foreach .[] as $item (0; . + $item)", "[1,2,3]", "[1, 3, 6]", 0,
  )
}

///|
test "corner: foreach with transformation" {
  assert_reference_query(
    "foreach .[] as $item (0; . + $item; . * 2)", "[1,2,3]", "[2, 6, 12]", 0,
  )
}

///|
test "corner: foreach with empty array" {
  assert_reference_query("foreach .[] as $item (0; . + $item)", "[]", "[]", 0)
}
