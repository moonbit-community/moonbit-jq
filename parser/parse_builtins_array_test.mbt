///|
/// Test parsing array built-in functions
test "parse map" {
  json_inspect(@parser.parse("map(. + 1)"), content=[
    "Located",
    { "start": 0, "end": 10 },
    [
      "FunctionCall",
      "map",
      [
        [
          "Located",
          { "start": 4, "end": 9 },
          [
            "Operation",
            ["Located", { "start": 4, "end": 5 }, "Identity"],
            "Add",
            ["Located", { "start": 8, "end": 9 }, ["Literal", ["Number", 1]]],
          ],
        ],
      ],
    ],
  ])
}

///|
test "parse select" {
  json_inspect(@parser.parse("select(. > 5)"), content=[
    "Located",
    { "start": 0, "end": 13 },
    [
      "FunctionCall",
      "select",
      [
        [
          "Located",
          { "start": 7, "end": 12 },
          [
            "Operation",
            ["Located", { "start": 7, "end": 8 }, "Identity"],
            "GreaterThan",
            ["Located", { "start": 11, "end": 12 }, ["Literal", ["Number", 5]]],
          ],
        ],
      ],
    ],
  ])
}

///|
test "parse sort" {
  json_inspect(@parser.parse("sort"), content=[
    "Located",
    { "start": 0, "end": 4 },
    ["FunctionCall", "sort", []],
  ])
}

///|
test "parse flatten" {
  json_inspect(@parser.parse("flatten"), content=[
    "Located",
    { "start": 0, "end": 7 },
    ["FunctionCall", "flatten", []],
  ])
  json_inspect(@parser.parse("flatten(2)"), content=[
    "Located",
    { "start": 0, "end": 10 },
    [
      "FunctionCall",
      "flatten",
      [["Located", { "start": 8, "end": 9 }, ["Literal", ["Number", 2]]]],
    ],
  ])
}
