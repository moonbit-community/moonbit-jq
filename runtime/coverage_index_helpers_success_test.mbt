///|
test "coverage: indices/index/rindex" {
  json_inspect(coverage_eval("indices(2)", "[1, 2, 1, 2]"), content=[[1, 3]])
  json_inspect(coverage_eval("index(2)", "[1, 2, 3]"), content=[1])
  json_inspect(coverage_eval("index(9)", "[1, 2, 3]"), content=[null])
  json_inspect(coverage_eval("rindex(\"o\")", "\"foobar\""), content=[2])
}
