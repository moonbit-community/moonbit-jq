///|
test "coverage: leaf_paths includes empty containers" {
  json_inspect(coverage_eval("leaf_paths", "{}"), content=[[]])
  json_inspect(coverage_eval("leaf_paths", "[]"), content=[[]])
}

///|
test "coverage: getpath early returns" {
  json_inspect(coverage_eval("getpath(empty)", "{\"a\": 1}"), content=[null])
  json_inspect(coverage_eval("getpath(1)", "{\"a\": 1}"), content=[null])
  json_inspect(coverage_eval("getpath([\"a\"])", "[1, 2]"), content=[null])
  json_inspect(coverage_eval("getpath([0])", "{\"a\": 1}"), content=[null])
}

///|
test "coverage: setpath edge cases" {
  json_inspect(coverage_eval("setpath([]; 1)", "{\"a\": 1}"), content=[1])
  json_inspect(coverage_eval("setpath(empty; 1)", "{\"a\": 1}"), content=[
    { "a": 1 },
  ])
  json_inspect(coverage_eval("setpath([\"a\"]; empty)", "{\"a\": 1}"), content=[
    { "a": 1 },
  ])
  json_inspect(coverage_eval("setpath(1; 2)", "{\"a\": 1}"), content=[
    { "a": 1 },
  ])
}

///|
test "coverage: delpaths edge cases" {
  json_inspect(coverage_eval("delpaths(empty)", "{\"a\": 1}"), content=[
    { "a": 1 },
  ])
  json_inspect(coverage_eval("delpaths(1)", "{\"a\": 1}"), content=[{ "a": 1 }])
  json_inspect(coverage_eval("delpaths([1, 2])", "{\"a\": 1}"), content=[
    { "a": 1 },
  ])
}

///|
test "coverage: until/while exit on empty" {
  json_inspect(coverage_eval("until(empty; . + 1)", "1"), content=[1])
  json_inspect(coverage_eval("until(. > 0; empty)", "0"), content=[0])
  json_inspect(coverage_eval("while(empty; . + 1)", "1"), content=[])
}
