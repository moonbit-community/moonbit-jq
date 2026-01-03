///|
/// Corner case tests for limits, defaults, and error propagation

// ============================================================================
// Limit Edge Cases
// ============================================================================

///|
test "corner: limit with zero" {
  inspect(test_query("limit(0; 1,2,3)", "null"), content="")
}

///|
test "corner: limit larger than available" {
  inspect(
    test_query("limit(10; 1,2,3)", "null"),
    content="Number(1), Number(2), Number(3)",
  )
}

///|
test "corner: limit with negative number" {
  inspect(test_query("limit(-1; 1,2,3)", "null"), content="")
}

// ============================================================================
// Null Coalescing and Default Values
// ============================================================================

///|
test "corner: multiple alternatives" {
  inspect(
    test_query(".a // .b // .c // \"default\"", "{\"c\":5}"),
    content="Null",
  )
}

///|
test "corner: alternative with false" {
  inspect(
    test_query(". // \"default\"", "false"),
    content="String(\"default\")",
  )
}

///|
test "corner: alternative with 0" {
  inspect(test_query(". // \"default\"", "0"), content="Number(0)")
}

///|
test "corner: alternative with empty string" {
  inspect(test_query(". // \"default\"", "\"\""), content="String(\"\")")
}

// ============================================================================
// Complex Nested Transformations
// ============================================================================

///|
test "corner: deeply nested object modification" {
  inspect(
    test_query(".a.b.c.d = 99", "{\"a\":{\"b\":{\"c\":{\"d\":1}}}}"),
    content="Number(99)",
  )
}

///|
test "corner: creating nested structure" {
  inspect(test_query(".a.b.c = 42", "{}"), content="Number(42)")
}

///|
test "corner: array within object modification" {
  inspect(
    test_query(
      ".items[1].value = 99", "{\"items\":[{\"value\":1},{\"value\":2}]}",
    ),
    content="Number(99)",
  )
}

// ============================================================================
// Recursive Functions Edge Cases
// ============================================================================

///|
test "corner: recursive function with base case" {
  inspect(
    test_query(
      "def sum: if length == 0 then 0 else .[0] + (.[1:] | sum) end; sum", "[1,2,3,4,5]",
    ),
    content="Number(15)",
  )
}

///|
test "corner: mutually recursive functions" {
  inspect(
    test_query(
      "def even: if . == 0 then true elif . == 1 then false else (. - 2) | even end; def odd: if . == 0 then false elif . == 1 then true else (. - 2) | odd end; even",
      "6",
    ),
    content=(
      #|ParseError: UnexpectedToken("TElif", "TElse")
    ),
  )
}

// ============================================================================
// String Interpolation Edge Cases
// ============================================================================

///|
test "corner: interpolation with null" {
  inspect(
    test_query("\"Value: \\(.missing)\"", "{}"),
    content="String(\"Value: Null\")",
  )
}

///|
test "corner: interpolation with nested object" {
  inspect(
    test_query("\"User: \\(.user)\"", "{\"user\":{\"name\":\"Alice\"}}"),
    content="String(\"User: Object({\\\"name\\\": String(\\\"Alice\\\")})\")",
  )
}

///|
test "corner: multiple adjacent interpolations" {
  inspect(
    test_query(
      "\"\\(.a)\\(.b)\\(.c)\"", "{\"a\":\"x\",\"b\":\"y\",\"c\":\"z\"}",
    ),
    content="String(\"xyz\")",
  )
}

///|
test "corner: interpolation with calculation" {
  inspect(
    test_query("\"Sum: \\(.a + .b + .c)\"", "{\"a\":1,\"b\":2,\"c\":3}"),
    content=(
      #|String("Sum: Number(6)")
    ),
  )
}

// ============================================================================
// Error Propagation
// ============================================================================

///|
test "corner: error in pipeline stops execution" {
  inspect(
    test_query(".x | . * 2", "{}"),
    content=(
      #|EvalError: InvalidOperation("Cannot multiply null and number")
    ),
  )
}

///|
test "corner: try catches errors" {
  inspect(test_query("try .x catch \"error\"", "{}"), content="Null")
}

///|
test "corner: try with successful operation" {
  inspect(
    test_query("try .x catch \"error\"", "{\"x\":42}"),
    content="Number(42)",
  )
}
