///|
/// Compiled jq query wrapper so the AST stays internal.
pub struct Query {
  expr : @ast.Expr
} derive(Debug)

///|
/// Methods on Query for direct control.
pub fn Query::eval(self : Query, input : Json) -> Iter[Json] raise {
  @ast.eval(self.expr, input)
}

///|
/// Evaluate this compiled query against one JSON input and collect every value
/// it produces.
///
/// This is the eager counterpart to `Query::eval`. It is convenient when the
/// full result set is small enough to keep in memory, while `Query::eval`
/// should be preferred for callers that want to stream results.
///
/// Raises if evaluation fails, for example when the query applies an operation
/// to an incompatible JSON type.
pub fn Query::eval_all(self : Query, input : Json) -> Array[Json] raise {
  self.eval(input).collect()
}

///|
/// Apply the query to newline-delimited JSON logs, skipping invalid lines.
pub fn Query::eval_logs(self : Query, logs : String) -> Iter[Json] raise {
  let aggregated : Array[Json] = []
  for raw_line in logs.split("\n") {
    let line = raw_line.strip_suffix("\r").unwrap_or(raw_line)
    if line.is_empty() {
      continue
    }
    let json_value = @json.parse(line) catch { _ => continue }
    for value in self.eval(json_value) {
      aggregated.push(value)
    }
  }
  aggregated.iter()
}
