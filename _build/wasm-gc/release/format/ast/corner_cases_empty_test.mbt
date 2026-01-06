///|
/// Corner case tests for empty outputs and error handling

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
