///|
/// Test parsing assignment operators
test "parse update" {
  json_inspect(@parser.parse(".foo |= . + 1"), content=[
    "Located",
    { "start": 0, "end": 13 },
    [
      "Update",
      ["Located", { "start": 0, "end": 4 }, ["Key", "foo"]],
      [
        "Located",
        { "start": 8, "end": 13 },
        [
          "Operation",
          ["Located", { "start": 8, "end": 9 }, "Identity"],
          "Add",
          ["Located", { "start": 12, "end": 13 }, ["Literal", ["Number", 1]]],
        ],
      ],
    ],
  ])
}

///|
test "parse alternative" {
  json_inspect(@parser.parse(".foo // .bar"), content=[
    "Located",
    { "start": 0, "end": 12 },
    [
      "Alternative",
      ["Located", { "start": 0, "end": 4 }, ["Key", "foo"]],
      ["Located", { "start": 8, "end": 12 }, ["Key", "bar"]],
    ],
  ])
}
