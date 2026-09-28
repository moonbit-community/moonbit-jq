///|
/// Evaluate Update operator: `p |= f`
fn eval_update(
  path : Expr,
  update_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  // jq 1.7's `_modify(paths; update)`: for each path, replace the value
  // with the first output of `f`; paths whose update is empty are deleted
  // at the end (all at once, so array indices do not shift).
  let mut updated = input
  let to_delete : Array[Array[Json]] = []
  for pair in path_values(path, input, env) {
    let current = get_at_path(updated, pair.0).unwrap_or(null)
    match eval_with_env(update_expr, current, env).collect() {
      [first, ..] => updated = set_at_path(updated, pair.0, first)
      [] => to_delete.push(pair.0)
    }
  }
  Iter::singleton(delete_paths(updated, to_delete.map(p => p)))
}
