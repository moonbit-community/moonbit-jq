///|
/// Test parsing optional operator
test "parse optional" {
  json_inspect(@parser.parse(".foo?"), content=[
    "Located",
    { "start": 0, "end": 5 },
    ["Optional", ["Located", { "start": 0, "end": 4 }, ["Key", "foo"]]],
  ])
}

///|
/// Test parsing variables
test "parse variable" {
  json_inspect(@parser.parse("$foo"), content=[
    "Located",
    { "start": 0, "end": 4 },
    ["Variable", "foo"],
  ])
}
