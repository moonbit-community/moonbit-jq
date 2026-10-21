///|
/// Test parsing array operations
test "parse array index" {
  json_inspect(@parser.parse(".[0]"), content=[
    "Located",
    { "start": 0, "end": 4 },
    [
      "Subscript",
      ["Located", { "start": 0, "end": 4 }, "Identity"],
      ["Located", { "start": 2, "end": 3 }, ["Literal", ["Number", 0]]],
    ],
  ])
}

///|
test "parse multiple indices" {
  json_inspect(@parser.parse(".[0,2,4]"), content=[
    "Located",
    { "start": 0, "end": 8 },
    [
      "Subscript",
      ["Located", { "start": 0, "end": 8 }, "Identity"],
      [
        "Located",
        { "start": 2, "end": 7 },
        [
          "Comma",
          [
            "Located",
            { "start": 2, "end": 5 },
            [
              "Comma",
              ["Located", { "start": 2, "end": 3 }, ["Literal", ["Number", 0]]],
              ["Located", { "start": 4, "end": 5 }, ["Literal", ["Number", 2]]],
            ],
          ],
          ["Located", { "start": 6, "end": 7 }, ["Literal", ["Number", 4]]],
        ],
      ],
    ],
  ])
}

///|
test "parse array iterator" {
  json_inspect(@parser.parse(".[]"), content=[
    "Located",
    { "start": 0, "end": 3 },
    [
      "Pipe",
      ["Located", { "start": 0, "end": 3 }, "Identity"],
      ["Located", { "start": 1, "end": 3 }, ["Index", []]],
    ],
  ])
}

///|
test "parse array slice" {
  json_inspect(@parser.parse(".[2:4]"), content=[
    "Located",
    { "start": 0, "end": 6 },
    [
      "Pipe",
      ["Located", { "start": 0, "end": 6 }, "Identity"],
      ["Located", { "start": 1, "end": 6 }, ["Slice", [2], [4]]],
    ],
  ])
}

///|
test "parse open-ended slices" {
  json_inspect(@parser.parse(".[2:]"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Pipe",
      ["Located", { "start": 0, "end": 5 }, "Identity"],
      ["Located", { "start": 1, "end": 5 }, ["Slice", [2], null]],
    ],
  ])
  json_inspect(@parser.parse(".[:4]"), content=[
    "Located",
    { "start": 0, "end": 5 },
    [
      "Pipe",
      ["Located", { "start": 0, "end": 5 }, "Identity"],
      ["Located", { "start": 1, "end": 5 }, ["Slice", null, [4]]],
    ],
  ])
}
