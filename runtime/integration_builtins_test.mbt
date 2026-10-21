///|
/// Test built-ins: length, keys, type
test "integration: built-in functions" {
  assert_reference_query("length", "[1,2,3,4,5]", "[5]", 0)
  assert_reference_query("length", "\"hello\"", "[5]", 0)
  assert_reference_query("keys", "{\"b\": 1, \"a\": 2}", "[[\"a\", \"b\"]]", 0)
  assert_reference_query("type", "42", "[\"number\"]", 0)
  assert_reference_query("type", "\"hi\"", "[\"string\"]", 0)
}

///|
/// Test map function
test "integration: map function" {
  assert_reference_query("map(. + 10)", "[1, 2, 3]", "[[11, 12, 13]]", 0)
  assert_reference_query("map(. * 2)", "[5, 10, 15]", "[[10, 20, 30]]", 0)
}

///|
/// Test select function
test "integration: select function" {
  assert_reference_query(".[] | select(. > 3)", "[1, 2, 3, 4, 5]", "[4, 5]", 0)
  assert_reference_query(".[] | select(. < 0)", "[1, 2, 3]", "[]", 0)
}

///|
/// Test array functions
test "integration: array functions" {
  assert_reference_query(
    "sort", "[3, 1, 4, 1, 5, 9, 2, 6]", "[[1, 1, 2, 3, 4, 5, 6, 9]]", 0,
  )
  assert_reference_query("reverse", "[1, 2, 3]", "[[3, 2, 1]]", 0)
  assert_reference_query("unique", "[1, 2, 1, 3, 2]", "[[1, 2, 3]]", 0)
}

///|
/// Test numeric functions
test "integration: numeric functions" {
  assert_reference_query("add", "[1, 2, 3, 4, 5]", "[15]", 0)
  assert_reference_query("min", "[5, 2, 8, 1]", "[1]", 0)
  assert_reference_query("max", "[5, 2, 8, 1]", "[8]", 0)
  assert_reference_query("floor", "3.7", "[3]", 0)
  assert_reference_query("sqrt", "16", "[4]", 0)
}
