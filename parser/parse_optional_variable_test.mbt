///|
/// Test parsing optional operator
test "parse optional" {
  json_inspect(@parser.parse(".foo?"), content=["Optional", ["Key", "foo"]])
}

///|
/// Test parsing variables
test "parse variable" {
  json_inspect(@parser.parse("$foo"), content=["Variable", "foo"])
}
