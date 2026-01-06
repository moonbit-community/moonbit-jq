///|
/// Parse numeric built-ins
fn Parser::parse_builtin_numeric(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "add" => Some(@ast.Expr::Add)
    "floor" => Some(@ast.Expr::Floor)
    "sqrt" => Some(@ast.Expr::Sqrt)
    "min" => Some(@ast.Expr::Min)
    "min_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::MinBy(expr))
    }
    "max" => Some(@ast.Expr::Max)
    "max_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::MaxBy(expr))
    }
    "round" => Some(@ast.Expr::Round)
    "ceil" => Some(@ast.Expr::Ceil)
    "abs" => Some(@ast.Expr::Abs)
    "pow" => {
      self.expect(TLParen)
      let base = self.parse_pipe()
      if self.consume(TSemicolon) {
        let exponent = self.parse_pipe()
        self.expect(TRParen)
        Some(@ast.Expr::Pipe(base, @ast.Expr::Pow(exponent)))
      } else {
        self.expect(TRParen)
        Some(@ast.Expr::Pow(base))
      }
    }
    "log" => Some(@ast.Expr::Log)
    "exp" => Some(@ast.Expr::Exp)
    "sin" => Some(@ast.Expr::Sin)
    "cos" => Some(@ast.Expr::Cos)
    "tan" => Some(@ast.Expr::Tan)
    "asin" => Some(@ast.Expr::Asin)
    "acos" => Some(@ast.Expr::Acos)
    "atan" => Some(@ast.Expr::Atan)
    _ => None
  }
}
