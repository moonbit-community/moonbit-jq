///|
test "coverage: ordering helper mismatches" {
  assert_coverage_eval_error("sort_by(.)", "1")
  assert_coverage_eval_error("group_by(.)", "1")
}

///|
test "coverage: index helpers edge cases" {
  assert_reference_query("indices(empty)", "[1, 2]", "[]", 0)
  assert_reference_query("indices(1)", "\"abc\"", "[]", 5)
  assert_coverage_eval_error("indices(1)", "{}")
  assert_reference_query("index(empty)", "[1, 2]", "[]", 0)
  assert_reference_query("index(\"z\")", "\"abc\"", "[null]", 0)
  assert_reference_query("index(1)", "\"abc\"", "[]", 5)
  assert_coverage_eval_error("index(1)", "{}")
  assert_reference_query("nth(5)", "[1]", "[null]", 0)
  assert_coverage_eval_error("nth(1)", "1")
  assert_reference_query("rindex(empty)", "[1]", "[]", 0)
  assert_reference_query("rindex(9)", "[1, 2]", "[null]", 0)
  assert_reference_query("rindex(\"z\")", "\"abc\"", "[null]", 0)
  assert_reference_query("rindex(1)", "\"abc\"", "[]", 5)
  assert_coverage_eval_error("rindex(1)", "{}")
}

///|
test "coverage: iterator helpers and path edges" {
  assert_reference_query("first", "[]", "[null]", 0)
  assert_reference_query("last", "[]", "[null]", 0)
  assert_coverage_eval_error("first", "1")
  assert_coverage_eval_error("last", "1")
  assert_coverage_eval_error("any", "1")
  assert_coverage_eval_error("all", "1")
  assert_reference_query(". >= 1", "1", "[true]", 0)
  assert_reference_query(". < []", "false", "[true]", 0)
  assert_reference_query("flatten(0)", "[1, [2]]", "[[1, [2]]]", 0)
  assert_reference_query("setpath([]; 1)", "{\"a\": 1}", "[1]", 0)
  json_inspect(coverage_eval("setpath([{}]; 1)", "{\"a\": 1}"), content=[
    { "a": 1 },
  ])
}

///|
test "coverage: parse_slice_part handles spaced negative index" {
  // Cover parser branch where '-' is tokenized separately from the number.
  assert_reference_query(".[- 1]", "[10, 20, 30]", "[30]", 0)
}
