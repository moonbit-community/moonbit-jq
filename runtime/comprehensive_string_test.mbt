///|
/// Comprehensive string-focused tests

// ============================================================================
// String Interpolation Tests
// ============================================================================

///|
test "string interpolation: basic" {
  assert_reference_query(
    "\"Hello \\(.name)!\"", "{\"name\":\"Alice\"}", "[\"Hello Alice!\"]", 0,
  )
}

///|
test "string interpolation: multiple expressions" {
  assert_reference_query(
    "\"\\(.first) \\(.last)\"", "{\"first\":\"John\",\"last\":\"Doe\"}", "[\"John Doe\"]",
    0,
  )
}

///|
test "string interpolation: nested access" {
  assert_reference_query(
    "\"Name: \\(.user.name), Age: \\(.user.age)\"", "{\"user\":{\"name\":\"Bob\",\"age\":30}}",
    "[\"Name: Bob, Age: 30\"]", 0,
  )
}

///|
test "string interpolation: with expressions" {
  assert_reference_query("\"Result: \\(. * 2)\"", "5", "[\"Result: 10\"]", 0)
}

///|
test "string interpolation: array access" {
  assert_reference_query(
    "\"First: \\(.[0]), Last: \\(.[-1])\"", "[1,2,3,4,5]", "[\"First: 1, Last: 5\"]",
    0,
  )
}

///|
test "string interpolation: complex expression" {
  assert_reference_query(
    "\"Sum: \\(.a + .b), Product: \\(.a * .b)\"", "{\"a\":3,\"b\":7}", "[\"Sum: 10, Product: 21\"]",
    0,
  )
}

// ============================================================================
// String Operations
// ============================================================================

///|
test "ltrimstr: remove prefix" {
  assert_reference_query(
    "ltrimstr(\"Hello \")", "\"Hello World\"", "[\"World\"]", 0,
  )
}

///|
test "rtrimstr: remove suffix" {
  assert_reference_query(
    "rtrimstr(\" World\")", "\"Hello World\"", "[\"Hello\"]", 0,
  )
}

///|
test "ascii_upcase: uppercase conversion" {
  assert_reference_query(
    "ascii_upcase", "\"hello world\"", "[\"HELLO WORLD\"]", 0,
  )
}

///|
test "ascii_downcase: lowercase conversion" {
  assert_reference_query(
    "ascii_downcase", "\"HELLO WORLD\"", "[\"hello world\"]", 0,
  )
}

///|
test "startswith: prefix check" {
  assert_reference_query(
    "startswith(\"Hello\")", "\"Hello World\"", "[true]", 0,
  )
}

///|
test "endswith: suffix check" {
  assert_reference_query("endswith(\"World\")", "\"Hello World\"", "[true]", 0)
}

///|
test "contains: substring check" {
  assert_reference_query("contains(\"lo Wo\")", "\"Hello World\"", "[true]", 0)
}

///|
test "split: split string" {
  assert_reference_query(
    "split(\",\")", "\"a,b,c\"", "[[\"a\", \"b\", \"c\"]]", 0,
  )
}

///|
test "join: join array elements" {
  assert_reference_query(
    "join(\"-\")", "[\"2024\",\"12\",\"13\"]", "[\"2024-12-13\"]", 0,
  )
}

// ============================================================================
// Edge Cases
// ============================================================================

///|
test "edge: unicode string interpolation" {
  assert_reference_query(
    "\"Hello \\(.name) 👋\"", "{\"name\":\"世界\"}", "[\"Hello 世界 👋\"]",
    0,
  )
}
