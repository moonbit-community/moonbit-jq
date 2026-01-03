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

///|
/// Test parsing arithmetic operators

test "parse addition" {
  @json.inspect(@parser.parse(". + 1"), content=[
    "Operation",
    "Identity",
    "Add",
    ["Literal", ["Number", 1]],
  ])
}

///|
test "parse subtraction" {
  @json.inspect(@parser.parse(". - 1"), content=[
    "Operation",
    "Identity",
    "Subtract",
    ["Literal", ["Number", 1]],
  ])
}

///|
test "parse multiplication" {
  @json.inspect(@parser.parse(". * 2"), content=[
    "Operation",
    "Identity",
    "Multiply",
    ["Literal", ["Number", 2]],
  ])
}

///|
test "parse division" {
  @json.inspect(@parser.parse(". / 2"), content=[
    "Operation",
    "Identity",
    "Divide",
    ["Literal", ["Number", 2]],
  ])
}

///|
test "parse modulo" {
  @json.inspect(@parser.parse(". % 2"), content=[
    "Operation",
    "Identity",
    "Modulo",
    ["Literal", ["Number", 2]],
  ])
}

///|
/// Test operator precedence

test "parse precedence: multiplication before addition" {
  @json.inspect(@parser.parse("1 + 2 * 3"), content=[
    "Operation",
    ["Literal", ["Number", 1]],
    "Add",
    [
      "Operation",
      ["Literal", ["Number", 2]],
      "Multiply",
      ["Literal", ["Number", 3]],
    ],
  ])
}

///|
test "parse parentheses override precedence" {
  @json.inspect(@parser.parse("(1 + 2) * 3"), content=[
    "Operation",
    ["Operation", ["Literal", ["Number", 1]], "Add", ["Literal", ["Number", 2]]],
    "Multiply",
    ["Literal", ["Number", 3]],
  ])
}

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

///|
/// Test parsing logical operators

test "parse and" {
  @json.inspect(@parser.parse(".a and .b"), content=[
    "Operation",
    ["Key", "a"],
    "And",
    ["Key", "b"],
  ])
}

///|
test "parse or" {
  @json.inspect(@parser.parse(".a or .b"), content=[
    "Operation",
    ["Key", "a"],
    "Or",
    ["Key", "b"],
  ])
}

///|
test "parse not" {
  @json.inspect(@parser.parse("not"), content="Not")
}
