///|
/// Test parsing comparison operators
test "parse equality" {
  json_inspect(@parser.parse(". == 5"), content=[
    "Located",
    { "start": 0, "end": 6 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "Equal",
      ["Located", { "start": 5, "end": 6 }, ["Literal", ["Number", 5]]],
    ],
  ])
}

///|
test "parse inequality" {
  json_inspect(@parser.parse(". != 5"), content=[
    "Located",
    { "start": 0, "end": 6 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "NotEqual",
      ["Located", { "start": 5, "end": 6 }, ["Literal", ["Number", 5]]],
    ],
  ])
}

///|
test "parse less than" {
  json_inspect(@parser.parse(". < 5"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "LessThan",
      ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 5]]],
    ],
  ])
}

///|
test "parse greater than" {
  json_inspect(@parser.parse(". > 5"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "GreaterThan",
      ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 5]]],
    ],
  ])
}
