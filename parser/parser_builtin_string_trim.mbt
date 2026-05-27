///|
/// Parse string trim and case built-ins
fn Parser::parse_builtin_string_trim(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "ltrimstr" => {
      self.expect(TLParen)
      guard self.current() is Some(TString(s)) else {
        raise InvalidSyntax("ltrimstr expects string argument")
      }
      self.advance()
      self.expect(TRParen)
      Some(LTrimStr(s))
    }
    "rtrimstr" => {
      self.expect(TLParen)
      guard self.current() is Some(TString(s)) else {
        raise InvalidSyntax("rtrimstr expects string argument")
      }
      self.advance()
      self.expect(TRParen)
      Some(RTrimStr(s))
    }
    "ascii_upcase" => Some(AsciiUpcase)
    "ascii_downcase" => Some(AsciiDowncase)
    _ => None
  }
}
