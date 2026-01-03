///|
/// Parse control and generator built-ins
fn Parser::parse_builtin_flow(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "range" => {
      self.expect(TLParen)
      let first_expr = self.parse_pipe()
      match self.current() {
        Some(TSemicolon) => {
          self.advance()
          let second_expr = self.parse_pipe()
          match self.current() {
            Some(TSemicolon) => {
              self.advance()
              let third_expr = self.parse_pipe()
              self.expect(TRParen)
              Some(@ast.Expr::RangeWithStep(first_expr, second_expr, third_expr))
            }
            _ => {
              self.expect(TRParen)
              Some(@ast.Expr::RangeFromTo(first_expr, second_expr))
            }
          }
        }
        _ => {
          self.expect(TRParen)
          match first_expr {
            @ast.Expr::Literal(@ast.Literal::Number(n)) =>
              Some(@ast.Expr::Range(n.to_int()))
            _ => raise InvalidSyntax("range(n) expects literal number")
          }
        }
      }
    }
    "first" =>
      match self.current() {
        Some(TLParen) => {
          self.advance()
          let expr = self.parse_pipe()
          self.expect(TRParen)
          Some(@ast.Expr::FirstGen(expr))
        }
        _ => Some(@ast.Expr::First)
      }
    "last" =>
      match self.current() {
        Some(TLParen) => {
          self.advance()
          let expr = self.parse_pipe()
          self.expect(TRParen)
          Some(@ast.Expr::LastGen(expr))
        }
        _ => Some(@ast.Expr::Last)
      }
    "repeat" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::Repeat(expr))
    }
    "any" =>
      match self.current() {
        Some(TLParen) => {
          self.advance()
          let gen_expr = self.parse_pipe()
          match self.current() {
            Some(TSemicolon) => {
              self.advance()
              let cond_expr = self.parse_pipe()
              self.expect(TRParen)
              Some(@ast.Expr::AnyGen(gen_expr, cond_expr))
            }
            _ => raise InvalidSyntax("any(gen; cond) expects semicolon")
          }
        }
        _ => Some(@ast.Expr::Any)
      }
    "all" =>
      match self.current() {
        Some(TLParen) => {
          self.advance()
          let gen_expr = self.parse_pipe()
          match self.current() {
            Some(TSemicolon) => {
              self.advance()
              let cond_expr = self.parse_pipe()
              self.expect(TRParen)
              Some(@ast.Expr::AllGen(gen_expr, cond_expr))
            }
            _ => raise InvalidSyntax("all(gen; cond) expects semicolon")
          }
        }
        _ => Some(@ast.Expr::All)
      }
    "limit" => {
      self.expect(TLParen)
      match self.current() {
        Some(TNumber(n)) => {
          self.advance()
          self.expect(TSemicolon)
          let expr = self.parse_pipe()
          self.expect(TRParen)
          Some(@ast.Expr::Limit(n.to_int(), expr))
        }
        _ => raise InvalidSyntax("limit expects number argument")
      }
    }
    "until" => {
      self.expect(TLParen)
      let cond = self.parse_pipe()
      self.expect(TSemicolon)
      let update = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::Until(cond, update))
    }
    "while" => {
      self.expect(TLParen)
      let cond = self.parse_pipe()
      self.expect(TSemicolon)
      let update = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::While(cond, update))
    }
    "reduce" => {
      self.expect(TLParen)
      let gen_expr = self.parse_postfix()
      self.expect(TAs)
      match self.current() {
        Some(TVariable(var_name)) => {
          self.advance()
          self.expect(TLParen)
          let init_expr = self.parse_pipe()
          self.expect(TSemicolon)
          let update_expr = self.parse_pipe()
          self.expect(TRParen)
          self.expect(TRParen)
          Some(@ast.Expr::Reduce(gen_expr, var_name, init_expr, update_expr))
        }
        _ => raise InvalidSyntax("reduce expects variable after as")
      }
    }
    "foreach" => {
      self.expect(TLParen)
      let gen_expr = self.parse_postfix()
      self.expect(TAs)
      match self.current() {
        Some(TVariable(var_name)) => {
          self.advance()
          self.expect(TLParen)
          let init_expr = self.parse_pipe()
          self.expect(TSemicolon)
          let update_expr = self.parse_pipe()
          let extract_expr = match self.current() {
            Some(TSemicolon) => {
              self.advance()
              Some(self.parse_pipe())
            }
            _ => None
          }
          self.expect(TRParen)
          self.expect(TRParen)
          Some(
            @ast.Expr::Foreach(
              gen_expr,
              var_name,
              init_expr,
              update_expr,
              extract_expr,
            ),
          )
        }
        _ => raise InvalidSyntax("foreach expects variable after as")
      }
    }
    "recurse" =>
      if self.consume(TLParen) {
        let f = self.parse_pipe()
        self.expect(TSemicolon)
        let cond = self.parse_pipe()
        self.expect(TRParen)
        Some(@ast.Expr::RecurseWith(f, cond))
      } else {
        Some(@ast.Expr::Recurse)
      }
    "walk" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::Walk(expr))
    }
    _ => None
  }
}
