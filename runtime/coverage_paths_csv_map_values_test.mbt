///|
test "coverage: paths(filter) traverses arrays" {
  assert_reference_query(
    "paths(type == \"number\")", "[1, [2]]", "[[0], [1, 0]]", 0,
  )
}

///|
test "coverage: @csv formats booleans and nulls" {
  assert_reference_query(
    "@csv", "[1, true, false, null, \"x\"]", "[\"1,true,false,,\\\"x\\\"\"]", 0,
  )
}

///|
test "coverage: map_values transforms object values" {
  assert_reference_query(
    "map_values(. + 1)", "{\"a\": 1, \"b\": 2}", "[{\"a\": 2, \"b\": 3}]", 0,
  )
}
