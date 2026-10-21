///|
/// Test array construction
test "integration: array construction" {
  json_inspect(jq("[.a, .b, .c]", "{\"a\": 1, \"b\": 2, \"c\": 3}"), content=[
    [1, 2, 3],
  ])
  json_inspect(jq("[.[] | . * 2]", "[1,2,3]"), content=[[2, 4, 6]])
}

///|
/// Test object construction
test "integration: object construction" {
  json_inspect(jq("{x: .a, y: .b}", "{\"a\": 10, \"b\": 20}"), content=[
    { "x": 10, "y": 20 },
  ])
  json_inspect(jq("{result: (. + 1)}", "5"), content=[{ "result": 6 }])
}
