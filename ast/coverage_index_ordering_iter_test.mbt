///|
test "coverage: ordering helper mismatches" {
  assert_coverage_eval_error("sort_by(.)", "1")
  assert_coverage_eval_error("group_by(.)", "1")
}

///|
test "coverage: index helpers edge cases" {
  json_inspect(coverage_eval("indices(empty)", "[1, 2]"), content=[[]])
  json_inspect(coverage_eval("indices(1)", "\"abc\""), content=[[]])
  assert_coverage_eval_error("indices(1)", "{}")
  json_inspect(coverage_eval("index(empty)", "[1, 2]"), content=[null])
  json_inspect(coverage_eval("index(\"z\")", "\"abc\""), content=[null])
  json_inspect(coverage_eval("index(1)", "\"abc\""), content=[null])
  assert_coverage_eval_error("index(1)", "{}")
  json_inspect(coverage_eval("nth(5)", "[1]"), content=[])
  assert_coverage_eval_error("nth(1)", "1")
  json_inspect(coverage_eval("rindex(empty)", "[1]"), content=[null])
  json_inspect(coverage_eval("rindex(9)", "[1, 2]"), content=[null])
  json_inspect(coverage_eval("rindex(\"z\")", "\"abc\""), content=[null])
  json_inspect(coverage_eval("rindex(1)", "\"abc\""), content=[null])
  assert_coverage_eval_error("rindex(1)", "{}")
}

///|
test "coverage: iterator helpers and path edges" {
  json_inspect(coverage_eval("first", "[]"), content=[])
  json_inspect(coverage_eval("last", "[]"), content=[])
  assert_coverage_eval_error("first", "1")
  assert_coverage_eval_error("last", "1")
  assert_coverage_eval_error("any", "1")
  assert_coverage_eval_error("all", "1")
  json_inspect(coverage_eval(". >= 1", "1"), content=[true])
  json_inspect(coverage_eval(". < []", "false"), content=[false])
  json_inspect(coverage_eval("flatten(0)", "[1, [2]]"), content=[[1, [2]]])
  json_inspect(coverage_eval("setpath([]; 1)", "{\"a\": 1}"), content=[1])
  json_inspect(coverage_eval("setpath([{}]; 1)", "{\"a\": 1}"), content=[
    { "a": 1 },
  ])
}

///|
test "coverage: parse_slice_part handles spaced negative index" {
  // Cover parser branch where '-' is tokenized separately from the number.
  json_inspect(coverage_eval(".[- 1]", "[10, 20, 30]"), content=[30])
}
