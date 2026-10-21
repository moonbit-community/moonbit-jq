///|
/// Helper for coverage tests
fn coverage_eval(query : String, input : String) -> Array[Json] raise {
  let expr = @parser.parse(query)
  let json_input = @json.parse(input)
  @runtime.eval_all(@runtime.compile(expr), json_input)
}

///|
fn assert_coverage_eval_error(query : String, input : String) -> Unit raise {
  try coverage_eval(query, input) catch {
    _ => ()
  } noraise {
    _ => fail("expected jq evaluation error")
  }
}
