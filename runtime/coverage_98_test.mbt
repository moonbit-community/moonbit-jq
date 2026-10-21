///|
test "coverage: update operator deep branches" {
  assert_reference_query(".[0] |= . + 1", "{\"a\":1}", "[]", 5)
  assert_reference_query(".a.b |= . + 1", "{}", "[{\"a\": {\"b\": 1}}]", 0)
  assert_reference_query(".a.b |= . + 1", "1", "[]", 5)
  assert_reference_query(
    "(.foo | .bar) |= . + 1", "{\"foo\":{\"bar\":1}}", "[{\"foo\": {\"bar\": 2}}]",
    0,
  )
  assert_reference_query(
    "(empty | .bar) |= . + 1", "{\"bar\":1}", "[{\"bar\": 1}]", 0,
  )
  // `length` is not a path expression, so jq rejects updating it.
  assert_coverage_eval_error("length |= empty", "{\"a\":1}")
  assert_coverage_eval_error("length |= 3", "[1,2]")
  assert_reference_query("empty |= 1", "{\"a\":1}", "[{\"a\": 1}]", 0)
}

///|
test "coverage: contains, inside, has, in fallbacks" {
  assert_reference_query("contains(\"a\")", "1", "[]", 5)
  assert_reference_query("inside(empty)", "\"a\"", "[]", 0)
  assert_reference_query("inside(\"abc\")", "\"b\"", "[true]", 0)
  assert_reference_query("inside(\"abc\")", "1", "[]", 5)
  assert_reference_query("has(\"a\")", "1", "[]", 5)
  assert_reference_query("in(empty)", "\"a\"", "[]", 0)
  assert_reference_query("in({\"a\":1})", "1", "[]", 5)
  assert_reference_query("in([1,2])", "\"a\"", "[]", 5)
  assert_reference_query("in(1)", "\"a\"", "[]", 5)
}

///|
test "coverage: getpath, while, delpaths edges" {
  assert_reference_query("getpath([1])", "[0]", "[null]", 0)
  assert_reference_query("while(. < 2; empty)", "1", "[1]", 0)
  json_inspect(coverage_eval("delpaths([[1,2]])", "\"x\""), content=["x"])
}

///|
test "coverage: builtin mismatch errors" {
  assert_coverage_eval_error("to_entries", "1")
  assert_coverage_eval_error("map_values(.)", "1")
  assert_coverage_eval_error("unique_by(.)", "1")
  assert_coverage_eval_error("transpose", "1")
  assert_coverage_eval_error("range(1; \"x\"; 1)", "null")
  assert_coverage_eval_error("1 % 0", "null")
}

///|
test "coverage: foreach, min_by, transpose, implode" {
  assert_reference_query("foreach .[] as $x (empty; . + $x)", "[1, 2]", "[]", 0)
  assert_reference_query("min_by(.)", "[2, 1]", "[1]", 0)
  json_inspect(coverage_eval("transpose", "[[1], 2]"), content=[[[1]]])
  json_inspect(coverage_eval("implode", "[97, \"x\"]"), content=["a"])
}
