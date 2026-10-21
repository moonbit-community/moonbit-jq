///|
/// Test parsing arithmetic operators
test "parse addition" {
  json_inspect(@parser.parse(". + 1"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "Add",
      ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 1]]],
    ],
  ])
}

///|
test "parse subtraction" {
  json_inspect(@parser.parse(". - 1"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "Subtract",
      ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 1]]],
    ],
  ])
}

///|
test "parse multiplication" {
  json_inspect(@parser.parse(". * 2"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "Multiply",
      ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 2]]],
    ],
  ])
}

///|
test "parse division" {
  json_inspect(@parser.parse(". / 2"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "Divide",
      ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 2]]],
    ],
  ])
}

///|
test "parse modulo" {
  json_inspect(@parser.parse(". % 2"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, "Identity"],
      "Modulo",
      ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 2]]],
    ],
  ])
}

///|
/// Test operator precedence
test "parse precedence: multiplication before addition" {
  json_inspect(@parser.parse("1 + 2 * 3"), content=[
    "Located",
    { "start": 0, "end": 9 },
    [
      "Operation",
      ["Located", { "start": 0, "end": 1 }, ["Literal", ["Number", 1]]],
      "Add",
      [
        "Located",
        { "start": 4, "end": 9 },
        [
          "Operation",
          ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 2]]],
          "Multiply",
          ["Located", { "start": 8, "end": 9 }, ["Literal", ["Number", 3]]],
        ],
      ],
    ],
  ])
}

///|
test "parse parentheses override precedence" {
  json_inspect(@parser.parse("(1 + 2) * 3"), content=[
    "Located",
    { "start": 0, "end": 11 },
    [
      "Operation",
      [
        "Located",
        { "start": 0, "end": 7 },
        [
          "Operation",
          ["Located", { "start": 1, "end": 2 }, ["Literal", ["Number", 1]]],
          "Add",
          ["Located", { "start": 5, "end": 6 }, ["Literal", ["Number", 2]]],
        ],
      ],
      "Multiply",
      ["Located", { "start": 10, "end": 11 }, ["Literal", ["Number", 3]]],
    ],
  ])
}
