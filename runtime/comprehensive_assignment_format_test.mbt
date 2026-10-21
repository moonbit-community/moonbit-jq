///|
/// Comprehensive tests for assignment operators and format functions

// ============================================================================
// Compound Assignment Operator Tests
// ============================================================================

///|
test "compound assignment: += with number" {
  assert_reference_query(".x += 5", "{\"x\":10}", "[{\"x\": 15}]", 0)
}

///|
test "compound assignment: -= with number" {
  assert_reference_query(".x -= 3", "{\"x\":10}", "[{\"x\": 7}]", 0)
}

///|
test "compound assignment: *= with number" {
  assert_reference_query(".x *= 3", "{\"x\":4}", "[{\"x\": 12}]", 0)
}

///|
test "compound assignment: /= with number" {
  assert_reference_query(".x /= 2", "{\"x\":20}", "[{\"x\": 10}]", 0)
}

///|
test "compound assignment: %= modulo" {
  assert_reference_query(".x %= 3", "{\"x\":10}", "[{\"x\": 1}]", 0)
}

///|
test "compound assignment: //= alternative" {
  assert_reference_query(
    ".x //= 42", "{\"y\":10}", "[{\"y\": 10, \"x\": 42}]", 0,
  )
}

///|
test "compound assignment: += with array concat" {
  assert_reference_query(
    ".items += [4,5]", "{\"items\":[1,2,3]}", "[{\"items\": [1, 2, 3, 4, 5]}]", 0,
  )
}

///|
test "compound assignment: += with string concat" {
  assert_reference_query(
    ".msg += \" World\"", "{\"msg\":\"Hello\"}", "[{\"msg\": \"Hello World\"}]",
    0,
  )
}

// ============================================================================
// Format Function Tests
// ============================================================================

///|
test "format: @base64 encoding" {
  assert_reference_query("@base64", "\"Hello\"", "[\"SGVsbG8=\"]", 0)
}

///|
test "format: @base64d decoding" {
  assert_reference_query("@base64d", "\"SGVsbG8=\"", "[\"Hello\"]", 0)
}

///|
test "format: @uri encoding" {
  assert_reference_query("@uri", "\"hello world\"", "[\"hello%20world\"]", 0)
}

///|
test "format: @html escaping" {
  assert_reference_query(
    "@html", "\"<div>Test</div>\"", "[\"&lt;div&gt;Test&lt;/div&gt;\"]", 0,
  )
}

///|
test "format: @csv simple array" {
  assert_reference_query(
    "@csv", "[\"a\",\"b\",\"c\"]", "[\"\\\"a\\\",\\\"b\\\",\\\"c\\\"\"]", 0,
  )
}

///|
test "format: @csv with quotes" {
  assert_reference_query(
    "@csv", "[\"hello, world\",\"test\"]", "[\"\\\"hello, world\\\",\\\"test\\\"\"]",
    0,
  )
}

///|
test "format: @tsv tab separated" {
  assert_reference_query("@tsv", "[\"a\",\"b\",\"c\"]", "[\"a\\tb\\tc\"]", 0)
}

///|
test "format: @json stringify" {
  assert_reference_query(
    "@json", "{\"x\":1,\"y\":2}", "[\"{\\\"x\\\":1,\\\"y\\\":2}\"]", 0,
  )
}

///|
test "format: @text" {
  assert_reference_query("@text", "{\"x\":42}", "[\"{\\\"x\\\":42}\"]", 0)
}
