///|
/// Test parsing arithmetic operators
test "parse addition" {
  json_inspect(@parser.parse(". + 1"), content=[
    "Operation",
    "Identity",
    "Add",
    ["Literal", ["Number", 1]],
  ])
}

///|
test "parse subtraction" {
  json_inspect(@parser.parse(". - 1"), content=[
    "Operation",
    "Identity",
    "Subtract",
    ["Literal", ["Number", 1]],
  ])
}

///|
test "parse multiplication" {
  json_inspect(@parser.parse(". * 2"), content=[
    "Operation",
    "Identity",
    "Multiply",
    ["Literal", ["Number", 2]],
  ])
}

///|
test "parse division" {
  json_inspect(@parser.parse(". / 2"), content=[
    "Operation",
    "Identity",
    "Divide",
    ["Literal", ["Number", 2]],
  ])
}

///|
test "parse modulo" {
  json_inspect(@parser.parse(". % 2"), content=[
    "Operation",
    "Identity",
    "Modulo",
    ["Literal", ["Number", 2]],
  ])
}

///|
/// Test operator precedence
test "parse precedence: multiplication before addition" {
  json_inspect(@parser.parse("1 + 2 * 3"), content=[
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
  json_inspect(@parser.parse("(1 + 2) * 3"), content=[
    "Operation",
    ["Operation", ["Literal", ["Number", 1]], "Add", ["Literal", ["Number", 2]]],
    "Multiply",
    ["Literal", ["Number", 3]],
  ])
}
