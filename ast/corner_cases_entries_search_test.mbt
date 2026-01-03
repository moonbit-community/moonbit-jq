///|
/// Corner case tests for entries and membership

// ============================================================================
// Map Values and Entries
// ============================================================================

///|
test "corner: map_values on object" {
  inspect(
    test_query("map_values(. * 2)", "{\"a\":1,\"b\":2,\"c\":3}"),
    content="Object({\"a\": Number(2), \"b\": Number(4), \"c\": Number(6)})",
  )
}

///|
test "corner: map_values on empty object" {
  inspect(test_query("map_values(. * 2)", "{}"), content="Object({})")
}

///|
test "corner: to_entries converts object to key-value pairs" {
  inspect(
    test_query("to_entries", "{\"a\":1,\"b\":2}"),
    content="Array([Object({\"key\": String(\"a\"), \"value\": Number(1)}), Object({\"key\": String(\"b\"), \"value\": Number(2)})])",
  )
}

///|
test "corner: from_entries converts back to object" {
  inspect(
    test_query(
      "from_entries", "[{\"key\":\"a\",\"value\":1},{\"key\":\"b\",\"value\":2}]",
    ),
    content="Object({\"a\": Number(1), \"b\": Number(2)})",
  )
}

///|
test "corner: with_entries transforms object entries" {
  inspect(
    test_query("with_entries(.value *= 2)", "{\"a\":1,\"b\":2}"),
    content="Object({\"a\": Number(2), \"b\": Number(4)})",
  )
}

///|
test "corner: with_entries filters entries" {
  inspect(
    test_query("with_entries(select(.value > 1))", "{\"a\":1,\"b\":2,\"c\":3}"),
    content="Object({\"b\": Number(2), \"c\": Number(3)})",
  )
}

// ============================================================================
// Array Search and Membership
// ============================================================================

///|
test "corner: indices finds all occurrences" {
  inspect(
    test_query("indices(2)", "[1,2,3,2,1]"),
    content="Array([Number(1), Number(3)])",
  )
}

///|
test "corner: indices with no matches" {
  inspect(test_query("indices(99)", "[1,2,3]"), content="Array([])")
}

///|
test "corner: inside checks array containment" {
  inspect(test_query("inside([1,2,3,4,5])", "[1,2]"), content="True")
}

///|
test "corner: inside with non-subset" {
  inspect(test_query("inside([1,2,3])", "[1,2,4]"), content="False")
}
