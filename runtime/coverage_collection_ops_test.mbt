///|
test "coverage: unique_by/min_by/max_by" {
  let input = "[{\"x\":1},{\"x\":1},{\"x\":2}]"
  json_inspect(coverage_eval("unique_by(.x)", input), content=[
    [{ "x": 1 }, { "x": 2 }],
  ])
  json_inspect(coverage_eval("min_by(.x)", input), content=[{ "x": 1 }])
  json_inspect(coverage_eval("max_by(.x)", input), content=[{ "x": 2 }])
}

///|
test "coverage: combinations and transpose" {
  json_inspect(coverage_eval("combinations", "[[1,2],[3,4]]"), content=[
    [1, 3],
    [1, 4],
    [2, 3],
    [2, 4],
  ])
  json_inspect(coverage_eval("combinations", "[[1], 2]"), content=[])
  json_inspect(coverage_eval("transpose", "[[1,2,3],[4,5]]"), content=[
    [[1, 4], [2, 5], [3]],
  ])
}

///|
test "coverage: flatten() parses and runs" {
  json_inspect(coverage_eval("flatten()", "[1, [2]]"), content=[[1, 2]])
}
