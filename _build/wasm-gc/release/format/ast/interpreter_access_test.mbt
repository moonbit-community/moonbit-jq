///|
/// Test field access
test "eval field access" {
  let results = test_eval(".name", "{\"name\": \"Alice\", \"age\": 30}")
  @json.inspect(results, content=["Alice"])
}

///|
test "eval missing field" {
  let results = test_eval(".missing", "{\"name\": \"Alice\"}")
  @json.inspect(results, content=[null])
}

///|
/// Test array operations
test "eval array index" {
  let results = test_eval(".[1]", "[10, 20, 30]")
  @json.inspect(results, content=[20])
}

///|
test "eval negative array index" {
  let results = test_eval(".[-1]", "[10, 20, 30]")
  @json.inspect(results, content=[30])
}

///|
test "eval array iterator" {
  let results = test_eval(".[]", "[1, 2, 3]")
  @json.inspect(results, content=[1, 2, 3])
}
