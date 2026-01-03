///|
/// Test complex expressions

test "parse complex filter" {
  @json.inspect(@parser.parse(".[] | select(.age > 18) | .name"), content=[
    "Pipe",
    [
      "Pipe",
      ["Pipe", "Identity", ["Index", []]],
      [
        "Select",
        [
          "Operation",
          ["Key", "age"],
          "GreaterThan",
          ["Literal", ["Number", 18]],
        ],
      ],
    ],
    ["Key", "name"],
  ])
}

///|
/// Test error handling

test "panic unexpected token" {
  inspect(
    try? @parser.parse("@"),
    content=(
      #|Err(UnexpectedToken(TAt, "expression"))
    ),
  )
}

///|
test "panic unexpected end" {
  inspect(
    try? @parser.parse("if .x then"),
    content=(
      #|Err(UnexpectedEnd("TElse"))
    ),
  )
}
