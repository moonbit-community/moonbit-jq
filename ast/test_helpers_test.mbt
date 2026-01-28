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

///|
struct InputQuery {
  query : String
  input : String

  fn new(query~ : String, input~ : String) -> InputQuery
}

///|
fn InputQuery::new(query~ : String, input~ : String) -> InputQuery {
  InputQuery::{ query, input }
}

///|
// FIXME: ArgsLoc can not be passed done due to arity 
// mismatch in macro expansion. 4 happesn to work
#callsite(autofill(args_loc, loc))
fn debug_query(
  iq : InputQuery,
  content? : String,
  loc~ : SourceLoc,
  args_loc~ : ArgsLoc,
) -> Unit raise {
  let output = test_query(iq.query, iq.input)
  inspect(output, content?, loc~, args_loc~)
}
