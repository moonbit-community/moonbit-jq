///|
/// Evaluate Assign operator: `p = v` sets every path of `p` to `v`, with
/// both `p` and `v` evaluated against the original input. One result is
/// produced per output of `v`.
fn eval_assign(
  path : Expr,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  let paths = path_values(path, input, env)
  let results : Array[Json] = []
  for value in eval_with_env(value_expr, input, env) {
    let mut updated = input
    for pair in paths {
      updated = set_at_path(updated, pair.0, value)
    }
    results.push(updated)
  }
  results.iter()
}
