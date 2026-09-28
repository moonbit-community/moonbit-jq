///|
/// Environment name holding the right-hand side of a compound assignment.
/// It contains a space, so no jq program can refer to it.
let compound_rhs_var : String = " rhs"

///|
/// Evaluate compound assignment with binary op.
///
/// As in jq 1.7, `p op= v` evaluates `v` against the original input and,
/// for each of its outputs `$x`, computes `p |= . op $x`; an empty `v`
/// produces no output.
fn eval_compound_assign(
  path : Expr,
  op : BinaryOp,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  let update = Operation(Identity, op, Variable(compound_rhs_var))
  let results : Array[Json] = []
  for value in eval_with_env(value_expr, input, env).collect() {
    let rhs_env = env.set(compound_rhs_var, value)
    for result in eval_update(path, update, input, rhs_env) {
      results.push(result)
    }
  }
  results.iter()
}

///|
/// Evaluate alternative assignment: `p //= v` is, for each output `$x` of
/// `v` (evaluated against the original input), `p |= (. // $x)`.
fn eval_alt_assign(
  path : Expr,
  value_expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  let update = Alternative(Identity, Variable(compound_rhs_var))
  let results : Array[Json] = []
  for value in eval_with_env(value_expr, input, env).collect() {
    let rhs_env = env.set(compound_rhs_var, value)
    for result in eval_update(path, update, input, rhs_env) {
      results.push(result)
    }
  }
  results.iter()
}
