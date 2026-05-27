///|
/// Parse numeric built-ins
fn Parser::parse_builtin_numeric(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "add" => Some(Add)
    "floor" => Some(Floor)
    "sqrt" => Some(Sqrt)
    "min" => Some(Min)
    "min_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(MinBy(expr))
    }
    "max" => Some(Max)
    "max_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(MaxBy(expr))
    }
    "round" => Some(Round)
    "ceil" => Some(Ceil)
    "abs" => Some(Abs)
    "pow" => {
      self.expect(TLParen)
      let base = self.parse_pipe()
      if self.consume(TSemicolon) {
        let exponent = self.parse_pipe()
        self.expect(TRParen)
        Some(Pipe(base, Pow(exponent)))
      } else {
        self.expect(TRParen)
        Some(Pow(base))
      }
    }
    "log" => Some(Log)
    "exp" => Some(Exp)
    "sin" => Some(Sin)
    "cos" => Some(Cos)
    "tan" => Some(Tan)
    "asin" => Some(Asin)
    "acos" => Some(Acos)
    "atan" => Some(Atan)
    _ => None
  }
}
