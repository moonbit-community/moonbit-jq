///|
/// Test parsing identity
test "parse identity" {
  let expr = @parser.parse(".")
  json_inspect(expr, content="Identity")
}
