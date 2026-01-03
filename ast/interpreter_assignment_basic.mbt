///|
/// Evaluate Assign operator
fn eval_assign(
  _path : Expr,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  let values = eval_with_env(value_expr, input, env).collect()
  if values.is_empty() {
    Iterator::singleton(input)
  } else {
    Iterator::singleton(values[0])
  }
}
