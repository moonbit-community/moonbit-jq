///|
/// Comprehensive edge case tests

///|
test "edge: empty array operations" {
  inspect(test_query(".[] | . * 2", "[]"), content="")
}

///|
test "edge: null handling" {
  inspect(
    test_query(".x // \"default\"", "null"),
    content="String(\"default\")",
  )
}

///|
test "edge: deeply nested access" {
  inspect(
    test_query(".a.b.c.d.e", "{\"a\":{\"b\":{\"c\":{\"d\":{\"e\":42}}}}}"),
    content="Number(42)",
  )
}

///|
test "edge: array bounds" {
  inspect(
    test_query(".[100] // \"out of bounds\"", "[1,2,3]"),
    content="String(\"out of bounds\")",
  )
}

///|
test "edge: type mixing" {
  inspect(test_query("type", "null"), content="String(\"null\")")
}
