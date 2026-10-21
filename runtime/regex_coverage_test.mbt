///|
test "coverage: test(pattern) returns boolean" {
  assert_reference_query("test(\"foo\")", "\"foobar\"", "[true]", 0)
  assert_reference_query("test(\"baz\")", "\"foobar\"", "[false]", 0)
}

///|
test "coverage: match(pattern) returns match object or empty" {
  json_inspect(coverage_eval("match(\"foo\")", "\"foobar\""), content=[
    {
      "match": "foo",
      "offset": 0,
      "length": 3,
      "string": "foobar",
      "captures": [],
    },
  ])
  assert_reference_query("match(\"zzz\")", "\"foobar\"", "[]", 0)
}

///|
test "coverage: capture(pattern) returns object" {
  assert_reference_query("capture(\"foo\")", "\"foobar\"", "[{}]", 0)
}

///|
test "coverage: splits(pattern) yields segments" {
  assert_reference_query(
    "splits(\"-\")", "\"a-b-c\"", "[\"a\", \"b\", \"c\"]", 0,
  )
}

///|
test "coverage: sub/gsub replace text" {
  assert_reference_query(
    "sub(\"world\"; \"moon\")", "\"hello world\"", "[\"hello moon\"]", 0,
  )
  assert_reference_query("gsub(\"a\"; \"b\")", "\"a a a\"", "[\"b b b\"]", 0)
}

///|
test "coverage: regex functions reject non-string input" {
  assert_coverage_eval_error("test(\"x\")", "1")
  assert_coverage_eval_error("match(\"x\")", "1")
  assert_coverage_eval_error("capture(\"x\")", "1")
  assert_coverage_eval_error("splits(\"x\")", "1")
  assert_coverage_eval_error("sub(\"x\"; \"y\")", "1")
  assert_coverage_eval_error("gsub(\"x\"; \"y\")", "1")
}
