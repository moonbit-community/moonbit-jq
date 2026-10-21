///|
/// Test parsing basic built-in functions
test "parse length" {
  json_inspect(@parser.parse("length"), content=[
    "Located",
    { "start": 0, "end": 6 },
    ["FunctionCall", "length", []],
  ])
}

///|
test "parse keys" {
  json_inspect(@parser.parse("keys"), content=[
    "Located",
    { "start": 0, "end": 4 },
    ["FunctionCall", "keys", []],
  ])
}

///|
test "parse type" {
  json_inspect(@parser.parse("type"), content=[
    "Located",
    { "start": 0, "end": 4 },
    ["FunctionCall", "type", []],
  ])
}
