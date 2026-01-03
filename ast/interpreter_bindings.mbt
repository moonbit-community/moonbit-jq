///|
/// Evaluate variable lookup
fn eval_variable(name : String, env : Env) -> Iterator[Json] raise InterpreterError {
  match env.get(name) {
    Some(v) => Iterator::singleton(v)
    None => raise InvalidOperation("Undefined variable: $\{name}")
  }
}

///|
/// Evaluate function call
fn eval_function_call(
  name : String,
  args : Array[Expr],
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  match env.get_function(name) {
    Some((body, params)) =>
      if params.is_empty() {
        eval_with_env(body, input, env)
      } else if args.length() != params.length() {
        raise EvalError(
          "Function \{name} expects \{params.length()} arguments, got \{args.length()}",
        )
      } else {
        let arg_values : Array[Json] = []
        for arg in args {
          let results = eval_with_env(arg, input, env).collect()
          arg_values.push(
            if results.is_empty() {
              null
            } else {
              results[0]
            },
          )
        }
        let mut new_env = env
        for i = 0; i < params.length(); i = i + 1 {
          new_env = new_env.set(params[i], arg_values[i])
        }
        eval_with_env(body, input, new_env)
      }
    None => raise EvalError("Undefined function: \{name}")
  }
}

///|
/// Evaluate As binding
fn eval_as(
  expr : Expr,
  var_name : String,
  body : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  let results = eval_with_env(expr, input, env).collect()
  let all_results : Array[Json] = []
  for result in results {
    let new_env = env.set(var_name, result)
    for val in eval_with_env(body, input, new_env) {
      all_results.push(val)
    }
  }
  all_results.iterator()
}
