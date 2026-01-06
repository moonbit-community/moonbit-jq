///|
/// Test pipe operator
test "eval pipe" {
  let results = test_eval(".numbers | .[0]", "{\"numbers\": [1, 2, 3]}")
  @json.inspect(results, content=[1])
}

///|
/// Test comma operator
test "eval comma produces multiple results" {
  let results = test_eval(".a, .b", "{\"a\": 1, \"b\": 2}")
  @json.inspect(results, content=[1, 2])
}

///|
test "eval comma with literals" {
  let results = test_eval("1, 2, 3", "null")
  @json.inspect(results, content=[1, 2, 3])
}

///|
/// Test arithmetic operators
test "eval addition" {
  let results = test_eval(".a + .b", "{\"a\": 10, \"b\": 5}")
  @json.inspect(results, content=[15])
}

///|
test "eval string concatenation" {
  let results = test_eval(
    ".first + .last", "{\"first\": \"Hello\", \"last\": \" World\"}",
  )
  @json.inspect(results, content=["Hello World"])
}

///|
test "eval subtraction" {
  let results = test_eval(".a - .b", "{\"a\": 10, \"b\": 3}")
  @json.inspect(results, content=[7])
}

///|
test "eval multiplication" {
  let results = test_eval(".a * .b", "{\"a\": 6, \"b\": 7}")
  @json.inspect(results, content=[42])
}

///|
test "eval division" {
  let results = test_eval(".a / .b", "{\"a\": 20, \"b\": 4}")
  @json.inspect(results, content=[5])
}

///|
/// Test comparison operators
test "eval equality" {
  let results = test_eval(".a == .b", "{\"a\": 5, \"b\": 5}")
  @json.inspect(results, content=[true])
}

///|
test "eval inequality" {
  let results = test_eval(".a != .b", "{\"a\": 5, \"b\": 3}")
  @json.inspect(results, content=[true])
}

///|
test "eval less than" {
  let results = test_eval(".a < .b", "{\"a\": 3, \"b\": 5}")
  @json.inspect(results, content=[true])
}
