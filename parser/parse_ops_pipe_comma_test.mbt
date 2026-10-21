///|
/// Test parsing pipe operator
test "parse pipe" {
  json_inspect(@parser.parse(". | .foo"), content=[
    "Located",
    { "start": 0, "end": 8 },
    [
      "Pipe",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      ["Located", { "start": 4, "end": 8 }, ["Key", "foo"]],
    ],
  ])
}

///|
test "parse chained pipes" {
  json_inspect(@parser.parse(".a | .b | .c"), content=[
    "Located",
    { "start": 0, "end": 12 },
    [
      "Pipe",
      ["Located", { "start": 0, "end": 2 }, ["Key", "a"]],
      [
        "Located",
        { "start": 5, "end": 12 },
        [
          "Pipe",
          ["Located", { "start": 5, "end": 7 }, ["Key", "b"]],
          ["Located", { "start": 10, "end": 12 }, ["Key", "c"]],
        ],
      ],
    ],
  ])
}

///|
/// Test parsing comma operator
test "parse comma" {
  json_inspect(@parser.parse(".a, .b"), content=[
    "Located",
    { "start": 0, "end": 6 },
    [
      "Comma",
      ["Located", { "start": 0, "end": 2 }, ["Key", "a"]],
      ["Located", { "start": 4, "end": 6 }, ["Key", "b"]],
    ],
  ])
}
