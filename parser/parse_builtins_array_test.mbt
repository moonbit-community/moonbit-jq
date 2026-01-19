///|
/// Test parsing array built-in functions
test "parse map" {
  json_inspect(@parser.parse("map(. + 1)"), content=[
    "Map",
    ["Operation", "Identity", "Add", ["Literal", ["Number", 1]]],
  ])
}

///|
test "parse select" {
  json_inspect(@parser.parse("select(. > 5)"), content=[
    "Select",
    ["Operation", "Identity", "GreaterThan", ["Literal", ["Number", 5]]],
  ])
}

///|
test "parse sort" {
  json_inspect(@parser.parse("sort"), content="Sort")
}

///|
test "parse flatten" {
  json_inspect(@parser.parse("flatten"), content=["Flatten", null])
  json_inspect(@parser.parse("flatten(2)"), content=["Flatten", [2]])
}
