///|
/// Compiled jq query wrapper so the AST stays internal.
pub struct Query {
  expr : @ast.Expr
}

///|
/// Methods on Query for direct control.
pub fn Query::eval(self : Query, input : Json) -> Iterator[Json] raise {
  @ast.eval(self.expr, input)
}

///|
pub fn Query::eval_all(self : Query, input : Json) -> Array[Json] raise {
  self.eval(input).collect()
}

///|
/// Apply the query to newline-delimited JSON logs, skipping invalid lines.
pub fn Query::eval_logs(self : Query, logs : String) -> Iterator[Json] raise {
  let aggregated : Array[Json] = []
  for raw_line in logs.split("\n") {
    let line = match raw_line.strip_suffix("\r"[:]) {
      Some(rest) => rest
      None => raw_line
    }
    if line.length() == 0 {
      continue
    }
    let json_value = @json.parse(line) catch { _ => continue }
    for value in self.eval(json_value) {
      aggregated.push(value)
    }
  }
  aggregated.iterator()
}
