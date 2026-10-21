///|
/// Comprehensive edge case tests

///|
test "edge: empty array operations" {
  assert_reference_query(".[] | . * 2", "[]", "[]", 0)
}

///|
test "edge: null handling" {
  assert_reference_query(".x // \"default\"", "null", "[\"default\"]", 0)
}

///|
test "edge: deeply nested access" {
  assert_reference_query(
    ".a.b.c.d.e", "{\"a\":{\"b\":{\"c\":{\"d\":{\"e\":42}}}}}", "[42]", 0,
  )
}

///|
test "edge: array bounds" {
  assert_reference_query(
    ".[100] // \"out of bounds\"", "[1,2,3]", "[\"out of bounds\"]", 0,
  )
}

///|
test "edge: type mixing" {
  assert_reference_query("type", "null", "[\"null\"]", 0)
}
