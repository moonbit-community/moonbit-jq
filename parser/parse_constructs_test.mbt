///|
/// Test parsing array constructor

test "parse empty array" {
  @json.inspect(@parser.parse("[]"), content=["ArrayConstruct", null])
}

///|
test "parse array with expression" {
  @json.inspect(@parser.parse("[.foo]"), content=[
    "ArrayConstruct",
    [["Key", "foo"]],
  ])
}

///|
/// Test parsing object constructor

test "parse empty object" {
  @json.inspect(@parser.parse("{}"), content=["ObjectConstruct", []])
}

///|
test "parse object with single field" {
  @json.inspect(@parser.parse("{foo: .bar}"), content=[
    "ObjectConstruct",
    [[["Literal", ["String", "foo"]], [["Key", "bar"]]]],
  ])
}

///|
test "parse object with multiple fields" {
  @json.inspect(@parser.parse("{a: .x, b: .y}"), content=[
    "ObjectConstruct",
    [
      [["Literal", ["String", "a"]], [["Key", "x"]]],
      [["Literal", ["String", "b"]], [["Key", "y"]]],
    ],
  ])
}

///|
/// Test parsing if-then-else

test "parse if-then-else" {
  @json.inspect(@parser.parse("if .x then .y else .z end"), content=[
    "IfThenElse",
    ["Key", "x"],
    ["Key", "y"],
    ["Key", "z"],
  ])
}

///|
/// Test parsing try-catch

test "parse try without catch" {
  @json.inspect(@parser.parse("try .foo"), content=[
    "TryCatch",
    ["Key", "foo"],
    null,
  ])
}

///|
test "parse try with catch" {
  @json.inspect(@parser.parse("try .foo catch .bar"), content=[
    "TryCatch",
    ["Key", "foo"],
    [["Key", "bar"]],
  ])
}

///|
/// Test parsing recurse

test "parse recurse" {
  @json.inspect(@parser.parse(".."), content="Recurse")
}
