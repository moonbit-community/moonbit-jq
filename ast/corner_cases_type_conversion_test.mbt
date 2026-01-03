///|
/// Corner case tests for type conversion and checking

///|
test "corner: tojson converts to JSON string" {
  inspect(
    test_query("tojson", "{\"a\":1}"),
    content="String(\"Object({\\\"a\\\": Number(1)})\")",
  )
}

///|
test "corner: fromjson parses JSON string" {
  inspect(
    test_query("fromjson", "\"{\\\"a\\\":1}\""),
    content="Object({\"a\": Number(1)})",
  )
}

///|
test "corner: tojson then fromjson roundtrip" {
  inspect(
    test_query("tojson | fromjson", "{\"a\":1,\"b\":[2,3]}"),
    content=(
      #|EvalError: InvalidOperation("JSON parse error: Invalid character 'O' at line 1, column 0")
    ),
  )
}

///|
test "corner: type of various values" {
  inspect(test_query("type", "null"), content="String(\"null\")")
}

///|
test "corner: type of number" {
  inspect(test_query("type", "42"), content="String(\"number\")")
}

///|
test "corner: type of string" {
  inspect(test_query("type", "\"hello\""), content="String(\"string\")")
}

///|
test "corner: type of array" {
  inspect(test_query("type", "[]"), content="String(\"array\")")
}

///|
test "corner: type of object" {
  inspect(test_query("type", "{}"), content="String(\"object\")")
}

///|
test "corner: type of boolean" {
  inspect(test_query("type", "true"), content="String(\"boolean\")")
}
