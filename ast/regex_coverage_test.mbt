///|
test "coverage: test(pattern) returns boolean" {
  json_inspect(coverage_eval("test(\"foo\")", "\"foobar\""), content=[true])
  json_inspect(coverage_eval("test(\"baz\")", "\"foobar\""), content=[false])
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
  json_inspect(coverage_eval("match(\"zzz\")", "\"foobar\""), content=[])
}

///|
test "coverage: capture(pattern) returns object" {
  json_inspect(coverage_eval("capture(\"foo\")", "\"foobar\""), content=[
    Json::empty_object(),
  ])
}

///|
test "coverage: splits(pattern) yields segments" {
  json_inspect(coverage_eval("splits(\"-\")", "\"a-b-c\""), content=[
    "a", "b", "c",
  ])
}

///|
test "coverage: sub/gsub replace text" {
  json_inspect(coverage_eval("sub(\"world\"; \"moon\")", "\"hello world\""), content=[
    "hello moon",
  ])
  json_inspect(coverage_eval("gsub(\"a\"; \"b\")", "\"a a a\""), content=[
    "b b b",
  ])
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
