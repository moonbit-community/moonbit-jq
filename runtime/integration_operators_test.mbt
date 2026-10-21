///|
/// Test pipe and comma
test "integration: pipe and comma" {
  assert_reference_query(". | . + 1", "5", "[6]", 0)
  assert_reference_query(".a | .b", "{\"a\": {\"b\": 42}}", "[42]", 0)
  assert_reference_query(".a, .b", "{\"a\": 1, \"b\": 2}", "[1, 2]", 0)
}

///|
/// Test arithmetic
test "integration: arithmetic" {
  assert_reference_query("1 + 2", "null", "[3]", 0)
  assert_reference_query("10 - 3", "null", "[7]", 0)
  assert_reference_query("6 * 7", "null", "[42]", 0)
  assert_reference_query("20 / 4", "null", "[5]", 0)
  assert_reference_query("17 % 5", "null", "[2]", 0)
}

///|
/// Test comparisons
test "integration: comparisons" {
  assert_reference_query("1 < 2", "null", "[true]", 0)
  assert_reference_query("5 > 10", "null", "[false]", 0)
  assert_reference_query("3 == 3", "null", "[true]", 0)
  assert_reference_query("4 != 5", "null", "[true]", 0)
}

///|
/// Test logical operators
test "integration: logical operators" {
  assert_reference_query("true and false", "null", "[false]", 0)
  assert_reference_query("true or false", "null", "[true]", 0)
  assert_reference_query("not", "true", "[false]", 0)
  assert_reference_query("not", "false", "[true]", 0)
}
