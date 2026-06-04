///|
/// Integration helper to parse and eval
fn jq(query : String, input : String) -> Array[Json] raise {
  let expr = @parser.parse(query)
  let json = @json.parse(input)
  @ast.eval(expr, json).collect()
}

///|
fn assert_jq_error(query : String, input : String) -> Unit raise {
  try jq(query, input) catch {
    _ => ()
  } noraise {
    _ => fail("expected jq evaluation error")
  }
}
