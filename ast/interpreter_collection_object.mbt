///|
/// Evaluate MapValues
fn eval_map_values(
  expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  guard input is Object(obj) else {
    raise TypeMismatch("object", @ast_internal.json_type_name(input))
  }
  let result : Map[String, Json] = {}
  for key, value in obj {
    let transformed_results = eval_with_env(expr, value, env).collect()
    match transformed_results {
      [first, ..] => result[key] = first
      _ => ()
    }
  }
  Iter::singleton(Json::object(result))
}
