///|
/// Helper to collect and inspect results
fn test_eval(query : String, input : String) -> Array[Json] raise {
  let expr = @parser.parse(query)
  let json_input = @json.parse(input)
  @ast.eval(expr, json_input).collect()
}
