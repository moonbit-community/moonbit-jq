///|
/// Test parsing field access
test "parse field access" {
  json_inspect(@parser.parse(".foo"), content=[
    "Located",
    { "start": 0, "end": 4 },
    ["Key", "foo"],
  ])
}

///|
test "parse nested field access" {
  json_inspect(@parser.parse(".foo.bar"), content=[
    "Located",
    { "start": 0, "end": 8 },
    [
      "Pipe",
      ["Located", { "start": 0, "end": 4 }, ["Key", "foo"]],
      ["Located", { "start": 4, "end": 8 }, ["Key", "bar"]],
    ],
  ])
}
