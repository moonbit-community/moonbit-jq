///|
/// Corner case tests for string interpolation

///|
test "corner: interpolation with null" {
  assert_reference_query(
    "\"Value: \\(.missing)\"", "{}", "[\"Value: null\"]", 0,
  )
}

///|
test "corner: interpolation with nested object" {
  assert_reference_query(
    "\"User: \\(.user)\"", "{\"user\":{\"name\":\"Alice\"}}", "[\"User: {\\\"name\\\":\\\"Alice\\\"}\"]",
    0,
  )
}

///|
test "corner: multiple adjacent interpolations" {
  assert_reference_query(
    "\"\\(.a)\\(.b)\\(.c)\"", "{\"a\":\"x\",\"b\":\"y\",\"c\":\"z\"}", "[\"xyz\"]",
    0,
  )
}

///|
test "corner: interpolation with calculation" {
  assert_reference_query(
    "\"Sum: \\(.a + .b + .c)\"", "{\"a\":1,\"b\":2,\"c\":3}", "[\"Sum: 6\"]", 0,
  )
}
