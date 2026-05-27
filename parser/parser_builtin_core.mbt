///|
/// Parse core built-ins
fn Parser::parse_builtin_core(_self : Parser, name : String) -> @ast.Expr? {
  match name {
    "length" => Some(Length)
    "keys" => Some(Keys)
    "values" => Some(Values)
    "type" => Some(Type)
    "empty" => Some(Empty)
    "not" => Some(Not)
    _ => None
  }
}
