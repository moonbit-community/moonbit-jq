///|
test "coverage: from_entries edge cases" {
  let input = "[{\"key\":\"a\"},{\"key\":1},{\"key\":{}},{\"value\":1},1]"
  @json.inspect(coverage_eval("from_entries", input), content=[{}])
  assert_true((try? coverage_eval("from_entries", "1")) is Err(_))
  assert_true((try? coverage_eval("with_entries(.)", "1")) is Err(_))
}
