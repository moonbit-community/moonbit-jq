///|
/// Test parsing literals
test "parse null literal" {
  let expr = @parser.parse("null")
  @json.inspect(expr, content=["Literal", "Null"])
}

///|
test "parse boolean literals" {
  @json.inspect(@parser.parse("true"), content=["Literal", ["Bool", true]])
  @json.inspect(@parser.parse("false"), content=["Literal", ["Bool", false]])
}

///|
test "parse number literals" {
  @json.inspect(@parser.parse("42"), content=["Literal", ["Number", 42]])
  @json.inspect(@parser.parse("3.14"), content=["Literal", ["Number", 3.14]])
}

///|
test "parse string literal" {
  @json.inspect(@parser.parse("\"hello\""), content=[
    "Literal",
    ["String", "hello"],
  ])
}
