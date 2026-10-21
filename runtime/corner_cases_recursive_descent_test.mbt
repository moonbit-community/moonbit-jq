///|
/// Corner case tests for recursive descent

///|
test "corner: recursive descent on nested arrays" {
  assert_reference_query(
    "[..]", "[1,[2,[3,[4]]]]", "[[[1, [2, [3, [4]]]], 1, [2, [3, [4]]], 2, [3, [4]], 3, [4], 4]]",
    0,
  )
}

///|
test "corner: recursive descent on nested objects" {
  assert_reference_query(
    "[..]", "{\"a\":{\"b\":{\"c\":1}}}", "[[{\"a\": {\"b\": {\"c\": 1}}}, {\"b\": {\"c\": 1}}, {\"c\": 1}, 1]]",
    0,
  )
}

///|
test "corner: recursive descent with filter" {
  assert_reference_query(
    "[.. | numbers]", "{\"a\":1,\"b\":{\"c\":2,\"d\":\"x\"}}", "[[1, 2]]", 0,
  )
}
