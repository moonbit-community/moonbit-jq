///|
/// Corner case tests for transpose

///|
test "corner: transpose matrix" {
  assert_reference_query(
    "transpose", "[[1,2,3],[4,5,6]]", "[[[1, 4], [2, 5], [3, 6]]]", 0,
  )
}

///|
test "corner: transpose with uneven rows" {
  debug_inspect(
    test_query("transpose", "[[1,2,3],[4,5],[6]]"),
    content=(
      #|"Array(\n  [\n    Array([Number(1), Number(4), Number(6)]),\n    Array([Number(2), Number(5)]),\n    Array([Number(3)]),\n  ],\n)"
    ),
  )
}

///|
test "corner: transpose empty matrix" {
  assert_reference_query("transpose", "[]", "[[]]", 0)
}
