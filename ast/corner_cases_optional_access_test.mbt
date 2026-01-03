///|
/// Corner case tests for optional access

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
