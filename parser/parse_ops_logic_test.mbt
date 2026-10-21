///|
/// Test parsing logical operators
test "parse and" {
  json_inspect(@parser.parse(".a and .b"), content=[
    "Located",
    { "start": 0, "end": 9 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 2 }, ["Key", "a"]],
      "And",
      ["Located", { "start": 7, "end": 9 }, ["Key", "b"]],
    ],
  ])
}

///|
test "parse or" {
  json_inspect(@parser.parse(".a or .b"), content=[
    "Located",
    { "start": 0, "end": 8 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 2 }, ["Key", "a"]],
      "Or",
      ["Located", { "start": 6, "end": 8 }, ["Key", "b"]],
    ],
  ])
}

///|
test "parse not" {
  json_inspect(@parser.parse("not"), content=[
    "Located",
    { "start": 0, "end": 3 },
    ["FunctionCall", "not", []],
  ])
}
