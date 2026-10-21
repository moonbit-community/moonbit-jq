///|
/// jq-compat tests for @uri

///|
test "jq compat: @uri encodes spaces as %20" {
  let results = coverage_eval("@uri", "\"a b\"")
  json_inspect(results, content=["a%20b"])
}

///|
test "jq compat: @uri encodes slash" {
  let results = coverage_eval("@uri", "\"a/b\"")
  json_inspect(results, content=["a%2Fb"])
}

///|
test "jq compat: @uri keeps unreserved characters" {
  let results = coverage_eval("@uri", "\"-_.~\"")
  json_inspect(results, content=["-_.~"])
}

///|
test "jq compat: @uri percent-encodes reserved punctuation" {
  assert_reference_query("@uri", "\"!\"", "[\"%21\"]", 0)
  assert_reference_query("@uri", "\"%\"", "[\"%25\"]", 0)
}

///|
test "jq compat: @uri percent-encodes utf8 bytes" {
  assert_reference_query("@uri", "\"中文\"", "[\"%E4%B8%AD%E6%96%87\"]", 0)
  assert_reference_query("@uri", "\"ÿ\"", "[\"%C3%BF\"]", 0)
}

///|
test "jq compat: @uri rejects non-string input" {
  assert_coverage_eval_error("@uri", "1")
}
