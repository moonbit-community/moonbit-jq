///|
test "coverage: arithmetic array subtraction and string repetition" {
  json_inspect(coverage_eval("[1,2,3] - [2]", "null"), content=[[1, 3]])
  json_inspect(coverage_eval("\"ab\" * 3", "null"), content=["ababab"])
  json_inspect(coverage_eval("3 * \"ab\"", "null"), content=["ababab"])
}
