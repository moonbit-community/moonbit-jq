///|
/// Parse string built-ins
fn Parser::parse_builtin_string(
  self : Parser,
  name : String,
) -> @ast.Expr? raise ParseError {
  match name {
    "split" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(sep)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Split(sep))
        }
        _ => raise InvalidSyntax("split expects string argument")
      }
    }
    "join" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(sep)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Join(sep))
        }
        _ => raise InvalidSyntax("join expects string argument")
      }
    }
    "startswith" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(prefix)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::StartsWith(prefix))
        }
        _ => raise InvalidSyntax("startswith expects string argument")
      }
    }
    "endswith" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(suffix)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::EndsWith(suffix))
        }
        _ => raise InvalidSyntax("endswith expects string argument")
      }
    }
    "contains" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::Contains(expr))
    }
    "inside" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      Some(@ast.Expr::Inside(expr))
    }
    "ltrimstr" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::LTrimStr(s))
        }
        _ => raise InvalidSyntax("ltrimstr expects string argument")
      }
    }
    "rtrimstr" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::RTrimStr(s))
        }
        _ => raise InvalidSyntax("rtrimstr expects string argument")
      }
    }
    "ascii_upcase" => Some(@ast.Expr::AsciiUpcase)
    "ascii_downcase" => Some(@ast.Expr::AsciiDowncase)
    "explode" => Some(@ast.Expr::Explode)
    "implode" => Some(@ast.Expr::Implode)
    "tojson" => Some(@ast.Expr::ToJsonString)
    "fromjson" => Some(@ast.Expr::FromJsonString)
    "scan" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Scan(s))
        }
        _ => raise InvalidSyntax("scan expects string argument")
      }
    }
    "test" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Test(s))
        }
        _ => raise InvalidSyntax("test expects string argument")
      }
    }
    "match" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Match(s))
        }
        _ => raise InvalidSyntax("match expects string argument")
      }
    }
    "capture" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Capture(s))
        }
        _ => raise InvalidSyntax("capture expects string argument")
      }
    }
    "splits" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          Some(@ast.Expr::Splits(s))
        }
        _ => raise InvalidSyntax("splits expects string argument")
      }
    }
    "sub" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(pattern)) => {
          self.advance()
          self.expect(TSemicolon)
          match self.current() {
            Some(TString(replacement)) => {
              self.advance()
              self.expect(TRParen)
              Some(@ast.Expr::Sub(pattern, replacement))
            }
            _ => raise InvalidSyntax("sub expects string replacement")
          }
        }
        _ => raise InvalidSyntax("sub expects string pattern")
      }
    }
    "gsub" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(pattern)) => {
          self.advance()
          self.expect(TSemicolon)
          match self.current() {
            Some(TString(replacement)) => {
              self.advance()
              self.expect(TRParen)
              Some(@ast.Expr::GSub(pattern, replacement))
            }
            _ => raise InvalidSyntax("gsub expects string replacement")
          }
        }
        _ => raise InvalidSyntax("gsub expects string pattern")
      }
    }
    _ => None
  }
}
