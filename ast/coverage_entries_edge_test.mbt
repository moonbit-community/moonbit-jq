///|
test "coverage: from_entries edge cases" {
  let input = "[{\"key\":\"a\"},{\"key\":1},{\"key\":{}},{\"value\":1},1]"
  json_inspect(coverage_eval("from_entries", input), content=[{}])
  assert_coverage_eval_error("from_entries", "1")
  assert_coverage_eval_error("with_entries(.)", "1")
}
