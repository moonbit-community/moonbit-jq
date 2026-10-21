///|
/// Test basic identity and field access
test "integration: basic queries" {
  assert_reference_query(".", "42", "[42]", 0)
  assert_reference_query(".foo", "{\"foo\": \"bar\"}", "[\"bar\"]", 0)
  assert_reference_query(".a.b", "{\"a\": {\"b\": 123}}", "[123]", 0)
}

///|
/// Test array operations
test "integration: array operations" {
  assert_reference_query(".[]", "[1,2,3]", "[1, 2, 3]", 0)
  assert_reference_query(".[1]", "[10,20,30]", "[20]", 0)
  assert_reference_query(".[-1]", "[10,20,30]", "[30]", 0)
  assert_reference_query(".[1:3]", "[1,2,3,4,5]", "[[2, 3]]", 0)
}

///|
/// Test string operations
test "integration: strings" {
  assert_reference_query(
    "\"hello\" + \" \" + \"world\"", "null", "[\"hello world\"]", 0,
  )
  assert_reference_query(
    ".first + .last", "{\"first\": \"Hello\", \"last\": \" MoonBit\"}", "[\"Hello MoonBit\"]",
    0,
  )
}
