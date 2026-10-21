///|
/// Compiled jq query with private, immutable execution-plan storage.
pub struct Query {
  priv plan : @runtime.Plan
} derive(Debug)

///|
/// Preserve method-style access to the derived debug representation.
pub extend Query with @debug.Debug::{to_repr}

///|
/// Methods on Query for direct control.
pub fn Query::eval(self : Query, input : Json) -> Iter[Result[Json, EvalError]] {
  @runtime.eval(self.plan, input)
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
pub fn Query::eval_all(
  self : Query,
  input : Json,
) -> Array[Json] raise EvalError {
  @runtime.eval_all(self.plan, input)
}

///|
/// Apply the query to newline-delimited JSON logs, skipping invalid lines.
pub fn Query::eval_logs(
  self : Query,
  logs : String,
) -> Iter[Result[Json, EvalError]] {
  let lines = logs.split("\n")
  let current : Ref[Iter[Result[Json, EvalError]]] = Ref(Iter::empty())
  let done = Ref(false)
  Iter::new(fn() {
    if done.val {
      return None
    }
    while true {
      if current.val.next() is Some(event) {
        if event is Err(_) {
          done.val = true
        }
        return Some(event)
      }
      guard lines.next() is Some(raw_line) else {
        done.val = true
        return None
      }
      let line = raw_line.strip_suffix("\r").unwrap_or(raw_line)
      let input = @json.parse(line) catch { _ => continue }
      current.val = self.eval(input)
    } nobreak {
      None
    }
  })
}
