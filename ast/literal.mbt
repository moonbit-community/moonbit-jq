///|
/// Literal values in jq expressions
pub(all) enum Literal {
  Null
  Bool(Bool)
  Number(Double)
  String(String)
} derive(Eq, ToJson, Debug)

///|
fn Literal::to_json(self : Literal) -> Json {
  match self {
    Null => null
    Bool(b) => Json::boolean(b)
    Number(n) => Json::number(n)
    String(s) => Json::string(s)
  }
}

///|
pub impl Show for Literal with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}
