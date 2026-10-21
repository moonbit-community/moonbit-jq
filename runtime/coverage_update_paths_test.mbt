///|
test "coverage: update operator supports chained paths and indices" {
  let input_obj : String =
    #|{
    #|  "a": { "b": 1 }
    #|}
  json_inspect(coverage_eval(".a.b |= . + 1", input_obj), content=[
    { "a": { "b": 2 } },
  ])
  assert_reference_query(".[1] |= . + 10", "[1, 2, 3]", "[[1, 12, 3]]", 0)
}

///|
test "coverage: delpaths deletes array indices" {
  assert_reference_query("delpaths([[1]])", "[10, 20, 30]", "[[10, 30]]", 0)
}

///|
test "coverage: getpath/setpath handle array segments" {
  assert_reference_query("getpath([1])", "[10, 20, 30]", "[20]", 0)
  assert_reference_query(
    "setpath([\"a\", \"b\"]; 2)", "{\"a\": {\"b\": 1}}", "[{\"a\": {\"b\": 2}}]",
    0,
  )
}

///|
test "coverage: setpath and delpaths for nested arrays" {
  assert_reference_query(
    "setpath([1]; 99)", "[10, 20, 30]", "[[10, 99, 30]]", 0,
  )
  assert_reference_query(
    "setpath([1, 0]; 99)", "[[0], [1, 2]]", "[[[0], [99, 2]]]", 0,
  )
  assert_reference_query(
    "delpaths([[1, 0]])", "[[0], [1, 2]]", "[[[0], [2]]]", 0,
  )
  assert_reference_query(
    "delpaths([[\"missing\", \"x\"]])", "{\"a\": 1}", "[{\"a\": 1}]", 0,
  )
}
