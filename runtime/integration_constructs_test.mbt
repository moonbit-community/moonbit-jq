///|
/// Test array construction
test "integration: array construction" {
  assert_reference_query(
    "[.a, .b, .c]", "{\"a\": 1, \"b\": 2, \"c\": 3}", "[[1, 2, 3]]", 0,
  )
  assert_reference_query("[.[] | . * 2]", "[1,2,3]", "[[2, 4, 6]]", 0)
}

///|
/// Test object construction
test "integration: object construction" {
  assert_reference_query(
    "{x: .a, y: .b}", "{\"a\": 10, \"b\": 20}", "[{\"x\": 10, \"y\": 20}]", 0,
  )
  assert_reference_query("{result: (. + 1)}", "5", "[{\"result\": 6}]", 0)
}
