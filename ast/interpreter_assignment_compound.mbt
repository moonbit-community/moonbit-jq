///|
/// Evaluate compound assignment with binary op
fn eval_compound_assign(
  path : Expr,
  op : BinaryOp,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  eval_with_env(Update(path, Operation(Identity, op, value_expr)), input, env)
}

///|
/// Evaluate alternative assignment
fn eval_alt_assign(
  path : Expr,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  eval_with_env(Update(path, Alternative(Identity, value_expr)), input, env)
}
