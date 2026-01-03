///|
/// Corner case tests for empty outputs and membership checks

// ============================================================================
// Empty and Error Handling
// ============================================================================

///|
test "corner: empty produces no output" {
  inspect(test_query("empty", "42"), content="")
}

///|
test "corner: empty in array construction" {
  inspect(
    test_query("[1, empty, 2]", "null"),
    content="Array([Number(1), Number(2)])",
  )
}

///|
test "corner: multiple values with comma" {
  inspect(
    test_query("1, 2, 3", "null"),
    content="Number(1), Number(2), Number(3)",
  )
}

///|
test "corner: empty array iteration" {
  inspect(test_query("[.[] | . * 2]", "[]"), content="Array([])")
}

// ============================================================================
// Object/Array Membership Tests
// ============================================================================

///|
test "corner: has() with existing key" {
  inspect(test_query("has(\"a\")", "{\"a\":1}"), content="True")
}

///|
test "corner: has() with missing key" {
  inspect(test_query("has(\"b\")", "{\"a\":1}"), content="False")
}

///|
test "corner: has() with array index" {
  inspect(test_query("has(0)", "[1,2,3]"), content="True")
}

///|
test "corner: has() with out of bounds index" {
  inspect(test_query("has(10)", "[1,2,3]"), content="False")
}

///|
test "corner: in() check key in object" {
  inspect(test_query("in({\"a\":1,\"b\":2})", "\"a\""), content="True")
}

///|
test "corner: in() check missing key" {
  inspect(test_query("in({\"a\":1,\"b\":2})", "\"c\""), content="False")
}
