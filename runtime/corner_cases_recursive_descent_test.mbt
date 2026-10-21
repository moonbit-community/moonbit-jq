///|
/// Corner case tests for recursive descent

///|
test "corner: recursive descent on nested arrays" {
  debug_inspect(
    test_query("[..]", "[1,[2,[3,[4]]]]"),
    content=(
      #|"Array(\n  [\n    Array(\n      [\n        Number(1),\n        Array([Number(2), Array([Number(3), Array([Number(4)])])]),\n      ],\n    ),\n    Number(1),\n    Array([Number(2), Array([Number(3), Array([Number(4)])])]),\n    Number(2),\n    Array([Number(3), Array([Number(4)])]),\n    Number(3),\n    Array([Number(4)]),\n    Number(4),\n  ],\n)"
    ),
  )
}

///|
test "corner: recursive descent on nested objects" {
  debug_inspect(
    test_query("[..]", "{\"a\":{\"b\":{\"c\":1}}}"),
    content=(
      #|"Array(\n  [\n    Object({ \"a\": Object({ \"b\": Object({ \"c\": Number(1) }) }) }),\n    Object({ \"b\": Object({ \"c\": Number(1) }) }),\n    Object({ \"c\": Number(1) }),\n    Number(1),\n  ],\n)"
    ),
  )
}

///|
test "corner: recursive descent with filter" {
  debug_inspect(
    test_query("[.. | numbers]", "{\"a\":1,\"b\":{\"c\":2,\"d\":\"x\"}}"),
    content=(
      #|"EvalError: EvalError(\"Undefined function: numbers\")"
    ),
  )
}
