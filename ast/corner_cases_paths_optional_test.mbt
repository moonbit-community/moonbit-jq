///|
/// Corner case tests for recursion, optional access, and paths

// ============================================================================
// Recursive Descent
// ============================================================================

///|
test "corner: recursive descent on nested arrays" {
  inspect(
    test_query("[..]", "[1,[2,[3,[4]]]]"),
    content="Array([Array([Number(1), Array([Number(2), Array([Number(3), Array([Number(4)])])])]), Number(1), Array([Number(2), Array([Number(3), Array([Number(4)])])]), Number(2), Array([Number(3), Array([Number(4)])]), Number(3), Array([Number(4)]), Number(4)])",
  )
}

///|
test "corner: recursive descent on nested objects" {
  inspect(
    test_query("[..]", "{\"a\":{\"b\":{\"c\":1}}}"),
    content="Array([Object({\"a\": Object({\"b\": Object({\"c\": Number(1)})})}), Object({\"b\": Object({\"c\": Number(1)})}), Object({\"c\": Number(1)}), Number(1)])",
  )
}

///|
test "corner: recursive descent with filter" {
  inspect(
    test_query("[.. | numbers]", "{\"a\":1,\"b\":{\"c\":2,\"d\":\"x\"}}"),
    content=(
      #|EvalError: EvalError("Undefined function: numbers")
    ),
  )
}

// ============================================================================
// Optional Access
// ============================================================================

///|
test "corner: optional object key access" {
  inspect(test_query(".a?", "{\"b\":1}"), content="Null")
}

///|
test "corner: optional array index" {
  inspect(test_query(".[10]?", "[1,2,3]"), content="Null")
}

///|
test "corner: optional nested access" {
  inspect(test_query(".a.b.c?", "{\"a\":{\"b\":{}}}"), content="Null")
}

///|
test "corner: optional with existing value" {
  inspect(test_query(".a?", "{\"a\":42}"), content="Number(42)")
}

// ============================================================================
// Array Slicing Edge Cases
// ============================================================================

///|
test "corner: negative start index" {
  inspect(
    test_query(".[-2:]", "[1,2,3,4,5]"),
    content="Array([Number(4), Number(5)])",
  )
}

///|
test "corner: negative end index" {
  inspect(
    test_query(".[:-2]", "[1,2,3,4,5]"),
    content="Array([Number(1), Number(2), Number(3)])",
  )
}

///|
test "corner: negative range" {
  inspect(
    test_query(".[-3:-1]", "[1,2,3,4,5]"),
    content="Array([Number(3), Number(4)])",
  )
}

///|
test "corner: slice beyond bounds" {
  inspect(test_query(".[10:20]", "[1,2,3]"), content="Array([])")
}

///|
test "corner: reverse slice" {
  inspect(test_query(".[3:1]", "[1,2,3,4,5]"), content="Array([])")
}

// ============================================================================
// Getpath with Non-Existent Paths
// ============================================================================

///|
test "corner: getpath returns null for non-existent path" {
  inspect(
    test_query("getpath([\"x\",\"y\",\"z\"])", "{\"a\":1}"),
    content="Null",
  )
}

///|
test "corner: getpath with empty path returns input" {
  inspect(
    test_query("getpath([])", "{\"a\":1}"),
    content="Object({\"a\": Number(1)})",
  )
}

// ============================================================================
// Path with Filter
// ============================================================================

///|
test "corner: paths with type filter" {
  inspect(
    test_query("paths(type == \"number\")", "{\"a\":{\"b\":1,\"c\":\"x\"}}"),
    content="Array([String(\"a\"), String(\"b\")])",
  )
}

///|
test "corner: paths scalars only" {
  inspect(test_query("paths(scalars)", "{\"a\":1,\"b\":{\"c\":2}}"), content="")
}
