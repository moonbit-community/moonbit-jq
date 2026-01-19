///|
test "coverage: setpath out-of-range keeps original" {
  json_inspect(coverage_eval("setpath([10]; 1)", "[0]"), content=[[0]])
}
