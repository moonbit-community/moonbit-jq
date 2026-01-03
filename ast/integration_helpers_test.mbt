///|
/// Integration helper to parse and eval
fn jq(query : String, input : String) -> Array[Json] raise {
  let expr = @parser.parse(query)
  let json = @json.parse(input)
  @ast.eval(expr, json).collect()
}
