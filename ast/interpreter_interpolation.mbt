///|
/// Evaluate string interpolation expressions
fn eval_string_interpolation(
  parts : Array[(String, Expr?)],
  input : Json,
  env : Env,
) -> Iterator[Json] raise InterpreterError {
  let buf = @buffer.new()
  for pair in parts {
    let (text, expr_opt) = pair
    buf.write_string(text)
    match expr_opt {
      Some(expr) => {
        let results = eval_with_env(expr, input, env).collect()
        if not(results.is_empty()) {
          match results[0] {
            String(s) => buf.write_string(s)
            _ => buf.write_string(results[0].to_string())
          }
        }
      }
      None => ()
    }
  }
  Iterator::singleton(Json::string(buf.to_string()))
}
