///|
/// jq-compat tests based on jq(1) behavior.
fn jq_eval(query : String, input : String) -> Array[Json] raise {
  let expr = @parser.parse(query)
  let json_input = @json.parse(input)
  @ast.eval(expr, json_input).collect()
}
