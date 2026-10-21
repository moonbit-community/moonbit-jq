///|
/// Helper to run jq queries
fn run_jq(query : String, input : String) -> Result[Array[Json], String] {
  let expr = @parser.parse(query) catch { e => return Err(e.to_string()) }
  let json = @json.parse(input) catch { e => return Err(e.to_string()) }
  let results = @runtime.eval_all(@runtime.compile(expr), json) catch {
    e => return Err(e.to_string())
  }
  Ok(results)
}
