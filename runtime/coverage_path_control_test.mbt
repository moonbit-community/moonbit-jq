///|
test "coverage: leaf_paths excludes the root and empty containers" {
  json_inspect(coverage_eval("leaf_paths", "{}"), content=[])
  json_inspect(coverage_eval("leaf_paths", "[]"), content=[])
}

///|
test "coverage: getpath early returns" {
  assert_reference_query("getpath(empty)", "{\"a\": 1}", "[]", 0)
  assert_reference_query("getpath(1)", "{\"a\": 1}", "[]", 5)
  assert_reference_query("getpath([\"a\"])", "[1, 2]", "[]", 5)
  assert_reference_query("getpath([0])", "{\"a\": 1}", "[]", 5)
}

///|
test "coverage: setpath edge cases" {
  assert_reference_query("setpath([]; 1)", "{\"a\": 1}", "[1]", 0)
  assert_reference_query("setpath(empty; 1)", "{\"a\": 1}", "[]", 0)
  assert_reference_query("setpath([\"a\"]; empty)", "{\"a\": 1}", "[]", 0)
  assert_reference_query("setpath(1; 2)", "{\"a\": 1}", "[]", 5)
}

///|
test "coverage: delpaths edge cases" {
  assert_reference_query("delpaths(empty)", "{\"a\": 1}", "[]", 0)
  assert_reference_query("delpaths(1)", "{\"a\": 1}", "[]", 5)
  assert_reference_query("delpaths([1, 2])", "{\"a\": 1}", "[]", 5)
}

///|
test "coverage: until/while exit on empty" {
  assert_reference_query("until(empty; . + 1)", "1", "[]", 0)
  assert_reference_query("until(. > 0; empty)", "0", "[]", 0)
  assert_reference_query("while(empty; . + 1)", "1", "[]", 0)
}
