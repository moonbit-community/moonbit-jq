///|
/// Test complex expressions
test "parse complex filter" {
  json_inspect(@parser.parse(".[] | select(.age > 18) | .name"), content=[
    "Located",
    { "start": 0, "end": 31 },
    [
      "Pipe",
      [
        "Located",
        { "start": 0, "end": 3 },
        [
          "Pipe",
          ["Located", { "start": 0, "end": 3 }, "Identity"],
          ["Located", { "start": 1, "end": 3 }, ["Index", []]],
        ],
      ],
      [
        "Located",
        { "start": 6, "end": 31 },
        [
          "Pipe",
          [
            "Located",
            { "start": 6, "end": 23 },
            [
              "FunctionCall",
              "select",
              [
                [
                  "Located",
                  { "start": 13, "end": 22 },
                  [
                    "Operation",
                    ["Located", { "start": 13, "end": 17 }, ["Key", "age"]],
                    "GreaterThan",
                    [
                      "Located",
                      { "start": 20, "end": 22 },
                      ["Literal", ["Number", 18]],
                    ],
                  ],
                ],
              ],
            ],
          ],
          ["Located", { "start": 26, "end": 31 }, ["Key", "name"]],
        ],
      ],
    ],
  ])
}
