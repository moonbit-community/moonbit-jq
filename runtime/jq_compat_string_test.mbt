///|
/// jq-compat tests for string helpers

///|
test "jq compat: split keeps empty segments" {
  let results = coverage_eval("split(\"/\")", "\"a/b//c/\"")
  json_inspect(results, content=[["a", "b", "", "c", ""]])
}

///|
test "jq compat: ltrimstr removes prefix only" {
  assert_reference_query("ltrimstr(\"foo\")", "\"foobar\"", "[\"bar\"]", 0)
  assert_reference_query("ltrimstr(\"bar\")", "\"foobar\"", "[\"foobar\"]", 0)
}

///|
test "jq compat: rtrimstr removes suffix only" {
  assert_reference_query("rtrimstr(\"bar\")", "\"foobar\"", "[\"foo\"]", 0)
  assert_reference_query("rtrimstr(\"baz\")", "\"foobar\"", "[\"foobar\"]", 0)
}

///|
test "jq compat: ascii_upcase/downcase only affects ASCII" {
  assert_reference_query("ascii_downcase", "\"AbÇ\"", "[\"abÇ\"]", 0)
  assert_reference_query("ascii_upcase", "\"AbÇ\"", "[\"ABÇ\"]", 0)
}
