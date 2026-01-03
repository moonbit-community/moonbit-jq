///|
/// Test parsing comparison operators
test "parse equality" {
  @json.inspect(@parser.parse(". == 5"), content=[
    "Operation",
    "Identity",
    "Equal",
    ["Literal", ["Number", 5]],
  ])
}

///|
test "parse inequality" {
  @json.inspect(@parser.parse(". != 5"), content=[
    "Operation",
    "Identity",
    "NotEqual",
    ["Literal", ["Number", 5]],
  ])
}

///|
test "parse less than" {
  @json.inspect(@parser.parse(". < 5"), content=[
    "Operation",
    "Identity",
    "LessThan",
    ["Literal", ["Number", 5]],
  ])
}

///|
test "parse greater than" {
  @json.inspect(@parser.parse(". > 5"), content=[
    "Operation",
    "Identity",
    "GreaterThan",
    ["Literal", ["Number", 5]],
  ])
}
