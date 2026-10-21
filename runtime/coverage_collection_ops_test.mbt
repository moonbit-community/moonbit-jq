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
  assert_reference_query(
    "combinations", "[[1,2],[3,4]]", "[[1, 3], [1, 4], [2, 3], [2, 4]]", 0,
  )
  assert_reference_query("combinations", "[[1], 2]", "[]", 5)
  json_inspect(coverage_eval("transpose", "[[1,2,3],[4,5]]"), content=[
    [[1, 4], [2, 5], [3]],
  ])
}

///|
test "coverage: flatten() parses and runs" {
  assert_reference_query("flatten()", "[1, [2]]", "[]", 3)
}
