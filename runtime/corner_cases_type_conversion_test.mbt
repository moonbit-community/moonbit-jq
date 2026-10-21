///|
/// Corner case tests for type conversion and checking

///|
test "corner: tojson converts to JSON string" {
  assert_reference_query("tojson", "{\"a\":1}", "[\"{\\\"a\\\":1}\"]", 0)
}

///|
test "corner: fromjson parses JSON string" {
  assert_reference_query("fromjson", "\"{\\\"a\\\":1}\"", "[{\"a\": 1}]", 0)
}

///|
test "corner: tojson then fromjson roundtrip" {
  assert_reference_query(
    "tojson | fromjson", "{\"a\":1,\"b\":[2,3]}", "[{\"a\": 1, \"b\": [2, 3]}]",
    0,
  )
}

///|
test "corner: type of various values" {
  assert_reference_query("type", "null", "[\"null\"]", 0)
}

///|
test "corner: type of number" {
  assert_reference_query("type", "42", "[\"number\"]", 0)
}

///|
test "corner: type of string" {
  assert_reference_query("type", "\"hello\"", "[\"string\"]", 0)
}

///|
test "corner: type of array" {
  assert_reference_query("type", "[]", "[\"array\"]", 0)
}

///|
test "corner: type of object" {
  assert_reference_query("type", "{}", "[\"object\"]", 0)
}

///|
test "corner: type of boolean" {
  assert_reference_query("type", "true", "[\"boolean\"]", 0)
}
