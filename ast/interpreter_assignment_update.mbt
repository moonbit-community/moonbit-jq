///|
/// Evaluate Update operator: `p |= f`
fn eval_update(
  path : Expr,
  update_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  // jq: `reduce path(p) as $q (.; setpath($q; getpath($q) | f))`, taking the
  // first output of `f`; a path whose update is empty is left unchanged.
  let mut updated = input
  for pair in path_values(path, input, env) {
    let current = get_at_path(updated, pair.0).unwrap_or(null)
    match eval_with_env(update_expr, current, env).collect() {
      [first, ..] => updated = set_at_path(updated, pair.0, first)
      [] => ()
    }
  }
  Iter::singleton(updated)
}
