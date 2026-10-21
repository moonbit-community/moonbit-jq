///|
/// Test parsing literals
test "parse null literal" {
  let expr = @parser.parse("null")
  json_inspect(expr, content=[
    "Located",
    { "start": 0, "end": 4 },
    ["Literal", "Null"],
  ])
}

///|
test "parse boolean literals" {
  json_inspect(@parser.parse("true"), content=[
    "Located",
    { "start": 0, "end": 4 },
    ["Literal", ["Bool", true]],
  ])
  json_inspect(@parser.parse("false"), content=[
    "Located",
    { "start": 0, "end": 5 },
    ["Literal", ["Bool", false]],
  ])
}

///|
test "parse number literals" {
  json_inspect(@parser.parse("42"), content=[
    "Located",
    { "start": 0, "end": 2 },
    ["Literal", ["Number", 42]],
  ])
  json_inspect(@parser.parse("3.14"), content=[
    "Located",
    { "start": 0, "end": 4 },
    ["Literal", ["Number", 3.14]],
  ])
}

///|
test "parse string literal" {
  json_inspect(@parser.parse("\"hello\""), content=[
    "Located",
    { "start": 0, "end": 7 },
    ["Literal", ["String", "hello"]],
  ])
}
