///|
/// Evaluate a literal to JSON
fn eval_literal(lit : Literal) -> Json {
  match lit {
    Null => null
    Bool(b) => Json::boolean(b)
    Number(n) => Json::number(n)
    String(s) => Json::string(s)
  }
}
