///|
/// Evaluate Assign operator: `p = v` sets every path of `p` to `v`, with
/// both `p` and `v` evaluated against the original input. One result is
/// produced per output of `v`.
///
/// As in jq 1.7 (`$__rhs as $v | reduce path(p) as $q (.; setpath($q;
/// $v))`), the right-hand side runs first, so the paths of `p` are only
/// computed when `v` has an output: `1 | length = empty` produces nothing
/// rather than an invalid-path error.
fn eval_assign(
  path : Expr,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  let values = eval_with_env(value_expr, input, env).collect()
  if values.is_empty() {
    return Iter::empty()
  }
  let paths = path_values(path, input, env)
  let results : Array[Json] = []
  for value in values {
    let mut updated = input
    for pair in paths {
      updated = set_at_path(updated, pair.0, value)
    }
    results.push(updated)
  }
  results.iter()
}
