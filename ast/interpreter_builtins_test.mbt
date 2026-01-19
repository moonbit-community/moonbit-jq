///|
/// Test built-in functions
test "eval length on array" {
  let results = test_eval("length", "[1, 2, 3, 4, 5]")
  json_inspect(results, content=[5])
}

///|
test "eval length on string" {
  let results = test_eval("length", "\"hello\"")
  json_inspect(results, content=[5])
}

///|
test "eval type" {
  json_inspect(test_eval("type", "42"), content=["number"])
  json_inspect(test_eval("type", "\"hello\""), content=["string"])
  json_inspect(test_eval("type", "null"), content=["null"])
}

///|
test "eval not" {
  let results = test_eval("not", "false")
  json_inspect(results, content=[true])
}
