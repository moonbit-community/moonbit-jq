///|
/// Corner case tests for optional access

///|
test "corner: optional object key access" {
  assert_reference_query(".a?", "{\"b\":1}", "[null]", 0)
}

///|
test "corner: optional array index" {
  assert_reference_query(".[10]?", "[1,2,3]", "[null]", 0)
}

///|
test "corner: optional nested access" {
  assert_reference_query(".a.b.c?", "{\"a\":{\"b\":{}}}", "[null]", 0)
}

///|
test "corner: optional with existing value" {
  assert_reference_query(".a?", "{\"a\":42}", "[42]", 0)
}
