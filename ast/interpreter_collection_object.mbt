///|
/// Evaluate MapValues
fn eval_map_values(
  expr : Expr,
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  match input {
    Object(obj) => {
      let result : Map[String, Json] = {}
      for key, value in obj {
        let transformed_results = eval_with_env(expr, value, env).collect()
        if not(transformed_results.is_empty()) {
          result[key] = transformed_results[0]
        }
      }
      Iterator::singleton(Json::object(result))
    }
    _ => raise TypeMismatch("object", json_type_name(input))
  }
}
