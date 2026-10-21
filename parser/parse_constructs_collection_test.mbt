///|
/// Test parsing array constructor
test "parse empty array" {
  json_inspect(@parser.parse("[]"), content=[
    "Located",
    { "start": 0, "end": 2 },
    ["ArrayConstruct", null],
  ])
}

///|
test "parse array with expression" {
  json_inspect(@parser.parse("[.foo]"), content=[
    "Located",
    { "start": 0, "end": 6 },
    ["ArrayConstruct", [["Located", { "start": 1, "end": 5 }, ["Key", "foo"]]]],
  ])
}

///|
/// Test parsing object constructor
test "parse empty object" {
  json_inspect(@parser.parse("{}"), content=[
    "Located",
    { "start": 0, "end": 2 },
    ["ObjectConstruct", []],
  ])
}

///|
test "parse object with single field" {
  json_inspect(@parser.parse("{foo: .bar}"), content=[
    "Located",
    { "start": 0, "end": 11 },
    [
      "ObjectConstruct",
      [
        [
          ["Located", { "start": 0, "end": 11 }, ["Literal", ["String", "foo"]]],
          [["Located", { "start": 6, "end": 10 }, ["Key", "bar"]]],
        ],
      ],
    ],
  ])
}

///|
test "parse object with multiple fields" {
  json_inspect(@parser.parse("{a: .x, b: .y}"), content=[
    "Located",
    { "start": 0, "end": 14 },
    [
      "ObjectConstruct",
      [
        [
          ["Located", { "start": 0, "end": 14 }, ["Literal", ["String", "a"]]],
          [["Located", { "start": 4, "end": 6 }, ["Key", "x"]]],
        ],
        [
          ["Located", { "start": 0, "end": 14 }, ["Literal", ["String", "b"]]],
          [["Located", { "start": 11, "end": 13 }, ["Key", "y"]]],
        ],
      ],
    ],
  ])
}
