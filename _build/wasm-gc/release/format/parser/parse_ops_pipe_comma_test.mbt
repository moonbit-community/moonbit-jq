///|
/// Test parsing pipe operator
test "parse pipe" {
  @json.inspect(@parser.parse(". | .foo"), content=[
    "Pipe",
    "Identity",
    ["Key", "foo"],
  ])
}

///|
test "parse chained pipes" {
  @json.inspect(@parser.parse(".a | .b | .c"), content=[
    "Pipe",
    ["Pipe", ["Key", "a"], ["Key", "b"]],
    ["Key", "c"],
  ])
}

///|
/// Test parsing comma operator
test "parse comma" {
  @json.inspect(@parser.parse(".a, .b"), content=[
    "Comma",
    ["Key", "a"],
    ["Key", "b"],
  ])
}
