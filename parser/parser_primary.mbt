///|
/// Parse primary expressions
fn Parser::parse_primary(self : Parser) -> @ast.Expr raise ParseError {
  match self.current() {
    Some(TNull) => {
      self.advance()
      Literal(Null)
    }
    Some(TTrue) => {
      self.advance()
      Literal(Bool(true))
    }
    Some(TFalse) => {
      self.advance()
      Literal(Bool(false))
    }
    Some(TNumber(n)) => {
      self.advance()
      Literal(Number(n))
    }
    Some(TString(s)) => {
      self.advance()
      Literal(String(s))
    }
    Some(TStringInterpolation(parts)) => {
      self.advance()
      let parsed_parts : Array[(String, @ast.Expr?)] = []
      for pair in parts {
        let (text, expr_opt) = pair
        match expr_opt {
          Some(expr_str) => {
            let expr_tokens = lex(expr_str) catch {
              _ => raise InvalidExpression("Failed to parse interpolation")
            }
            let expr_parser = Parser::new(expr_tokens)
            let expr = expr_parser.parse_pipe()
            parsed_parts.push((text, Some(expr)))
          }
          None => parsed_parts.push((text, None))
        }
      }
      StringInterpolation(parsed_parts)
    }
    Some(TDotDot) => {
      self.advance()
      Recurse
    }
    Some(TDot) => {
      self.advance()
      match self.current() {
        Some(TIdentifier(name)) => {
          self.advance()
          Key(name)
        }
        Some(TLBracket) => {
          self.advance()
          self.parse_index_or_slice(Identity)
        }
        _ => Identity
      }
    }
    Some(TVariable(name)) => {
      self.advance()
      Variable(name)
    }
    Some(TFormat(name)) => {
      self.advance()
      Format(name)
    }
    Some(TLParen) => {
      self.advance()
      let expr = self.parse_pipe()
      self.expect(TRParen)
      expr
    }
    Some(TLBracket) => {
      self.advance()
      if self.consume(TRBracket) {
        ArrayConstruct(None)
      } else {
        let expr = self.parse_pipe()
        self.expect(TRBracket)
        ArrayConstruct(Some(expr))
      }
    }
    Some(TLBrace) => {
      self.advance()
      self.parse_object()
    }
    Some(TIf) => self.parse_if()
    Some(TTry) => self.parse_try()
    Some(TReduce) => self.parse_reduce()
    Some(TForeach) => self.parse_foreach()
    Some(TIdentifier(name)) => {
      self.advance()
      self.parse_builtin(name)
    }
    Some(t) => raise UnexpectedToken(t.to_string(), "expression")
    None => raise UnexpectedEnd("expression")
  }
}
