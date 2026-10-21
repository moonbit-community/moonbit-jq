///|
/// Test parsing if-then-else
test "parse if-then-else" {
  json_inspect(@parser.parse("if .x then .y else .z end"), content=[
    "Located",
    { "start": 0, "end": 25 },
    [
      "IfThenElse",
      ["Located", { "start": 3, "end": 5 }, ["Key", "x"]],
      ["Located", { "start": 11, "end": 13 }, ["Key", "y"]],
      ["Located", { "start": 19, "end": 21 }, ["Key", "z"]],
    ],
  ])
}

///|
/// Test parsing try-catch
test "parse try without catch" {
  json_inspect(@parser.parse("try .foo"), content=[
    "Located",
    { "start": 0, "end": 8 },
    ["TryCatch", ["Located", { "start": 4, "end": 8 }, ["Key", "foo"]], null],
  ])
}

///|
test "parse try with catch" {
  json_inspect(@parser.parse("try .foo catch .bar"), content=[
    "Located",
    { "start": 0, "end": 19 },
    [
      "TryCatch",
      ["Located", { "start": 4, "end": 8 }, ["Key", "foo"]],
      [["Located", { "start": 15, "end": 19 }, ["Key", "bar"]]],
    ],
  ])
}

///|
/// Test parsing recurse
test "parse recurse" {
  json_inspect(@parser.parse(".."), content=[
    "Located",
    { "start": 0, "end": 2 },
    ["FunctionCall", "recurse", []],
  ])
}
