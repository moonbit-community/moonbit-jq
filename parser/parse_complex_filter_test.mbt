///|
/// Test complex expressions
test "parse complex filter" {
  json_inspect(@parser.parse(".[] | select(.age > 18) | .name"), content=[
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
