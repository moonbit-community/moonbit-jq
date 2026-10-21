///|
/// Test built-in functions
test "eval length on array" {
  let results = coverage_eval("length", "[1, 2, 3, 4, 5]")
  json_inspect(results, content=[5])
}

///|
test "eval length on string" {
  let results = coverage_eval("length", "\"hello\"")
  json_inspect(results, content=[5])
}

///|
test "eval type" {
  assert_reference_query("type", "42", "[\"number\"]", 0)
  assert_reference_query("type", "\"hello\"", "[\"string\"]", 0)
  assert_reference_query("type", "null", "[\"null\"]", 0)
}

///|
test "eval not" {
  let results = coverage_eval("not", "false")
  json_inspect(results, content=[true])
}
