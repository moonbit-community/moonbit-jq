///|
/// Test parsing identity
test "parse identity" {
  let expr = @parser.parse(".")
  json_inspect(expr, content=["Located", { "start": 0, "end": 1 }, "Identity"])
}
