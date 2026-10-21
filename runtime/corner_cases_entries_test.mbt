///|
/// Corner case tests for entries and map_values

///|
test "corner: map_values on object" {
  assert_reference_query(
    "map_values(. * 2)", "{\"a\":1,\"b\":2,\"c\":3}", "[{\"a\": 2, \"b\": 4, \"c\": 6}]",
    0,
  )
}

///|
test "corner: map_values on empty object" {
  assert_reference_query("map_values(. * 2)", "{}", "[{}]", 0)
}

///|
test "corner: to_entries converts object to key-value pairs" {
  assert_reference_query(
    "to_entries", "{\"a\":1,\"b\":2}", "[[{\"key\": \"a\", \"value\": 1}, {\"key\": \"b\", \"value\": 2}]]",
    0,
  )
}

///|
test "corner: from_entries converts back to object" {
  assert_reference_query(
    "from_entries", "[{\"key\":\"a\",\"value\":1},{\"key\":\"b\",\"value\":2}]",
    "[{\"a\": 1, \"b\": 2}]", 0,
  )
}

///|
test "corner: with_entries transforms object entries" {
  assert_reference_query(
    "with_entries(.value *= 2)", "{\"a\":1,\"b\":2}", "[{\"a\": 2, \"b\": 4}]", 0,
  )
}

///|
test "corner: with_entries filters entries" {
  assert_reference_query(
    "with_entries(select(.value > 1))", "{\"a\":1,\"b\":2,\"c\":3}", "[{\"b\": 2, \"c\": 3}]",
    0,
  )
}
