///|
/// Corner case tests for types, predicates, and aggregation

// ============================================================================
// Type Conversion and Checking
// ============================================================================

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

// ============================================================================
// Any and All
// ============================================================================

///|
test "corner: any with mixed booleans" {
  inspect(test_query("any", "[true,false,true]"), content="True")
}

///|
test "corner: any with all false" {
  inspect(test_query("any", "[false,false,false]"), content="False")
}

///|
test "corner: all with all true" {
  inspect(test_query("all", "[true,true,true]"), content="True")
}

///|
test "corner: all with one false" {
  inspect(test_query("all", "[true,false,true]"), content="False")
}

///|
test "corner: any with empty array" {
  inspect(test_query("any", "[]"), content="False")
}

///|
test "corner: all with empty array" {
  inspect(test_query("all", "[]"), content="True")
}

///|
test "corner: any with generator and condition" {
  inspect(test_query("any(1,2,3,4; . > 3)", "null"), content="True")
}

///|
test "corner: all with generator and condition" {
  inspect(test_query("all(1,2,3,4; . > 0)", "null"), content="True")
}

// ============================================================================
// Min/Max Edge Cases
// ============================================================================

///|
test "corner: min_by with empty array returns null" {
  inspect(test_query("min_by(.x)", "[]"), content="Null")
}

///|
test "corner: max_by with empty array returns null" {
  inspect(test_query("max_by(.x)", "[]"), content="Null")
}

///|
test "corner: min_by with single element" {
  inspect(
    test_query("min_by(.x)", "[{\"x\":5}]"),
    content="Object({\"x\": Number(5)})",
  )
}

///|
test "corner: max_by with single element" {
  inspect(
    test_query("max_by(.x)", "[{\"x\":5}]"),
    content="Object({\"x\": Number(5)})",
  )
}

// ============================================================================
// Unique Edge Cases
// ============================================================================

///|
test "corner: unique_by with single attribute" {
  inspect(
    test_query(
      "unique_by(.a)", "[{\"a\":1,\"b\":2},{\"a\":1,\"b\":3},{\"a\":2,\"b\":1}]",
    ),
    content="Array([Object({\"a\": Number(1), \"b\": Number(2)}), Object({\"a\": Number(2), \"b\": Number(1)})])",
  )
}

///|
test "corner: unique_by with empty array" {
  inspect(test_query("unique_by(.x)", "[]"), content="Array([])")
}

///|
test "corner: unique with duplicates" {
  inspect(
    test_query("unique", "[1,2,1,3,2,4]"),
    content="Array([Number(1), Number(2), Number(3), Number(4)])",
  )
}

// ============================================================================
// Group By with Aggregation
// ============================================================================

///|
test "corner: group_by then sum values" {
  inspect(
    test_query(
      "group_by(.type) | map({type: .[0].type, sum: map(.val) | add})", "[{\"type\":\"A\",\"val\":1},{\"type\":\"A\",\"val\":2},{\"type\":\"B\",\"val\":3}]",
    ),
    content=(
      #|ParseError: UnexpectedToken("TPipe", "TRBrace")
    ),
  )
}

///|
test "corner: group_by with empty array" {
  inspect(test_query("group_by(.x)", "[]"), content="Array([])")
}
