///|
/// Test identity
test "eval identity" {
  let results = test_eval(".", "42")
  @json.inspect(results, content=[42])
}

///|
test "eval identity with object" {
  let results = test_eval(".", "{\"a\": 1}")
  @json.inspect(results, content=[{ "a": 1 }])
}

///|
/// Test literals
test "eval null literal" {
  let results = test_eval("null", "42")
  @json.inspect(results, content=[null])
}

///|
test "eval number literal" {
  let results = test_eval("123", "{}")
  @json.inspect(results, content=[123])
}

///|
test "eval string literal" {
  let results = test_eval("\"hello\"", "null")
  @json.inspect(results, content=["hello"])
}
