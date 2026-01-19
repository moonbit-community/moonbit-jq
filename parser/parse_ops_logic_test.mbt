///|
/// Test parsing logical operators
test "parse and" {
  json_inspect(@parser.parse(".a and .b"), content=[
    "Operation",
    ["Key", "a"],
    "And",
    ["Key", "b"],
  ])
}

///|
test "parse or" {
  json_inspect(@parser.parse(".a or .b"), content=[
    "Operation",
    ["Key", "a"],
    "Or",
    ["Key", "b"],
  ])
}

///|
test "parse not" {
  json_inspect(@parser.parse("not"), content="Not")
}
