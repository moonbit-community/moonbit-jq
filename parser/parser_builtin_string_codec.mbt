///|
/// Parse string codec built-ins
fn Parser::parse_builtin_string_codec(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "explode" => Some(Explode)
    "implode" => Some(Implode)
    "tojson" => Some(ToJsonString)
    "fromjson" => Some(FromJsonString)
    "scan" => {
      self.expect(TLParen)
      guard self.current() is Some(TString(s)) else {
        raise InvalidSyntax("scan expects string argument")
      }
      self.advance()
      self.expect(TRParen)
      Some(Scan(s))
    }
    _ => None
  }
}
