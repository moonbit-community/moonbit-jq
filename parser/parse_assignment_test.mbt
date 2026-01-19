///|
/// Test parsing assignment operators
test "parse update" {
  json_inspect(@parser.parse(".foo |= . + 1"), content=[
    "Update",
    ["Key", "foo"],
    ["Operation", "Identity", "Add", ["Literal", ["Number", 1]]],
  ])
}

///|
test "parse alternative" {
  json_inspect(@parser.parse(".foo // .bar"), content=[
    "Alternative",
    ["Key", "foo"],
    ["Key", "bar"],
  ])
}
