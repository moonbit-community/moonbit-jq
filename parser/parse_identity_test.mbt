///|
/// Test parsing identity
test "parse identity" {
  let expr = @parser.parse(".")
  @json.inspect(expr, content="Identity")
}
