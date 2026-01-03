///|
/// Common test helper for jq query evaluation
fn test_query(query : String, input : String) -> String {
  let expr = @parser.parse(query) catch { e => return "ParseError: \{e}" }
  let json = @json.parse(input) catch { e => return "JsonParseError: \{e}" }
  let results = @ast.eval(expr, json) catch { e => return "EvalError: \{e}" }
  let outputs : Array[String] = []
  for result in results {
    outputs.push(result.to_string())
  }
  outputs.join(", ")
}
