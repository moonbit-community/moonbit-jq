///|
/// Parse built-in functions
fn Parser::parse_builtin(
  self : Parser,
  name : String,
) -> @ast.Expr raise ParseError {
  match name {
    "length" => @ast.Expr::Length
    "keys" => @ast.Expr::Keys
    "values" => @ast.Expr::Values
    "type" => @ast.Expr::Type
    "empty" => @ast.Expr::Empty
    "not" => @ast.Expr::Not
    "map" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::Map(expr)
    }
    "select" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::Select(expr)
    }
    "sort" => @ast.Expr::Sort
    "reverse" => @ast.Expr::Reverse
    "flatten" =>
      if self.consume(TLParen) {
        match self.current() {
          Some(TNumber(n)) => {
            self.advance()
            self.expect(TRParen)
            @ast.Expr::Flatten(Some(n.to_int()))
          }
          _ => {
            self.expect(TRParen)
            @ast.Expr::Flatten(None)
          }
        }
      } else {
        @ast.Expr::Flatten(None)
      }
    "unique" => @ast.Expr::Unique
    "unique_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::UniqueBy(expr)
    }
    "combinations" => @ast.Expr::Combinations
    "transpose" => @ast.Expr::Transpose
    "add" => @ast.Expr::Add
    "floor" => @ast.Expr::Floor
    "sqrt" => @ast.Expr::Sqrt
    "min" => @ast.Expr::Min
    "min_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::MinBy(expr)
    }
    "max" => @ast.Expr::Max
    "max_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::MaxBy(expr)
    }
    "round" => @ast.Expr::Round
    "ceil" => @ast.Expr::Ceil
    "abs" => @ast.Expr::Abs
    "split" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(sep)) => {
          self.advance()
          self.expect(TRParen)
          @ast.Expr::Split(sep)
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
          @ast.Expr::Join(sep)
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
          @ast.Expr::StartsWith(prefix)
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
          @ast.Expr::EndsWith(suffix)
        }
        _ => raise InvalidSyntax("endswith expects string argument")
      }
    }
    "contains" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::Contains(expr)
    }
    "inside" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::Inside(expr)
    }
    "has" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(key)) => {
          self.advance()
          self.expect(TRParen)
          @ast.Expr::Has(key)
        }
        Some(TNumber(n)) => {
          self.advance()
          self.expect(TRParen)
          @ast.Expr::Has(n.to_string())
        }
        _ => raise InvalidSyntax("has expects string or number argument")
      }
    }
    "in" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::In(expr)
    }
    "to_entries" => @ast.Expr::ToEntries
    "from_entries" => @ast.Expr::FromEntries
    "with_entries" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::WithEntries(expr)
    }
    "map_values" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::MapValues(expr)
    }
    "range" => {
      self.expect(TLParen)
      let first_expr = self.parse_pipe()
      // Check for semicolon to distinguish range(n) from range(from;to) or range(from;to;step)
      match self.current() {
        Some(TSemicolon) => {
          self.advance() // consume semicolon
          let second_expr = self.parse_pipe()
          match self.current() {
            Some(TSemicolon) => {
              // range(from;to;step)
              self.advance()
              let third_expr = self.parse_pipe()
              self.expect(TRParen)
              @ast.Expr::RangeWithStep(first_expr, second_expr, third_expr)
            }
            _ => {
              // range(from;to)
              self.expect(TRParen)
              @ast.Expr::RangeFromTo(first_expr, second_expr)
            }
          }
        }
        _ => {
          // range(n) - single argument
          self.expect(TRParen)
          // Convert expr to literal int if possible
          match first_expr {
            @ast.Expr::Literal(@ast.Literal::Number(n)) =>
              @ast.Expr::Range(n.to_int())
            _ => raise InvalidSyntax("range(n) expects literal number")
          }
        }
      }
    }
    "first" =>
      // Check if there's a parenthesis for first(generator)
      match self.current() {
        Some(TLParen) => {
          self.advance()
          let expr = self.parse_pipe()
          self.expect(TRParen)
          @ast.Expr::FirstGen(expr)
        }
        _ => @ast.Expr::First
      }
    "last" =>
      match self.current() {
        Some(TLParen) => {
          self.advance()
          let expr = self.parse_pipe()
          self.expect(TRParen)
          @ast.Expr::LastGen(expr)
        }
        _ => @ast.Expr::Last
      }
    "repeat" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::Repeat(expr)
    }
    "explode" => @ast.Expr::Explode
    "implode" => @ast.Expr::Implode
    "tojson" => @ast.Expr::ToJsonString
    "fromjson" => @ast.Expr::FromJsonString
    "indices" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::IndicesOf(expr)
    }
    "index" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::IndexOf(expr)
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
              @ast.Expr::AnyGen(gen_expr, cond_expr)
            }
            _ => raise InvalidSyntax("any(gen; cond) expects semicolon")
          }
        }
        _ => @ast.Expr::Any
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
              @ast.Expr::AllGen(gen_expr, cond_expr)
            }
            _ => raise InvalidSyntax("all(gen; cond) expects semicolon")
          }
        }
        _ => @ast.Expr::All
      }
    "sort_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::SortBy(expr)
    }
    "group_by" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::GroupBy(expr)
    }
    "ltrimstr" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          @ast.Expr::LTrimStr(s)
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
          @ast.Expr::RTrimStr(s)
        }
        _ => raise InvalidSyntax("rtrimstr expects string argument")
      }
    }
    "ascii_upcase" => @ast.Expr::AsciiUpcase
    "ascii_downcase" => @ast.Expr::AsciiDowncase
    "nth" => {
      self.expect(TLParen)
      match self.current() {
        Some(TNumber(n)) => {
          self.advance()
          self.expect(TRParen)
          @ast.Expr::Nth(n.to_int())
        }
        _ => raise InvalidSyntax("nth expects number argument")
      }
    }
    "rindex" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::RIndex(expr)
    }
    "paths" =>
      match self.current() {
        Some(TLParen) => {
          self.advance()
          let expr = self.parse_pipe()
          self.expect(TRParen)
          @ast.Expr::PathsWithFilter(expr)
        }
        _ => @ast.Expr::Paths
      }
    "leaf_paths" => @ast.Expr::LeafPaths
    "getpath" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::GetPath(expr)
    }
    "setpath" => {
      self.expect(TLParen)
      let path = self.parse_pipe()
      self.expect(TSemicolon)
      let value = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::SetPath(path, value)
    }
    "delpaths" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::DelPaths(expr)
    }
    "limit" => {
      self.expect(TLParen)
      match self.current() {
        Some(TNumber(n)) => {
          self.advance()
          self.expect(TSemicolon)
          let expr = self.parse_pipe()
          self.expect(TRParen)
          @ast.Expr::Limit(n.to_int(), expr)
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
      @ast.Expr::Until(cond, update)
    }
    "while" => {
      self.expect(TLParen)
      let cond = self.parse_pipe()
      self.expect(TSemicolon)
      let update = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::While(cond, update)
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
          @ast.Expr::Reduce(gen_expr, var_name, init_expr, update_expr)
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
          // Check for optional extract expression
          let extract_expr = match self.current() {
            Some(TSemicolon) => {
              self.advance()
              Some(self.parse_pipe())
            }
            _ => None
          }
          self.expect(TRParen)
          self.expect(TRParen)
          @ast.Expr::Foreach(
            gen_expr, var_name, init_expr, update_expr, extract_expr,
          )
        }
        _ => raise InvalidSyntax("foreach expects variable after as")
      }
    }
    "scan" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          @ast.Expr::Scan(s)
        }
        _ => raise InvalidSyntax("scan expects string argument")
      }
    }
    "recurse" =>
      if self.consume(TLParen) {
        let f = self.parse_pipe()
        self.expect(TSemicolon)
        let cond = self.parse_pipe()
        self.expect(TRParen)
        @ast.Expr::RecurseWith(f, cond)
      } else {
        @ast.Expr::Recurse
      }
    "walk" => {
      self.expect(TLParen)
      let expr = self.parse_pipe()
      self.expect(TRParen)
      @ast.Expr::Walk(expr)
    }
    "pow" => {
      self.expect(TLParen)
      let base = self.parse_pipe()
      // Check if we have semicolon separator for two-argument form
      if self.consume(TSemicolon) {
        let exponent = self.parse_pipe()
        self.expect(TRParen)
        // For pow(base; exponent), create an expression that applies both
        // This will be: base | pow(exponent)
        @ast.Expr::Pipe(base, @ast.Expr::Pow(exponent))
      } else {
        self.expect(TRParen)
        @ast.Expr::Pow(base)
      }
    }
    "log" => @ast.Expr::Log
    "exp" => @ast.Expr::Exp
    "sin" => @ast.Expr::Sin
    "cos" => @ast.Expr::Cos
    "tan" => @ast.Expr::Tan
    "asin" => @ast.Expr::Asin
    "acos" => @ast.Expr::Acos
    "atan" => @ast.Expr::Atan
    "test" => {
      self.expect(TLParen)
      match self.current() {
        Some(TString(s)) => {
          self.advance()
          self.expect(TRParen)
          @ast.Expr::Test(s)
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
          @ast.Expr::Match(s)
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
          @ast.Expr::Capture(s)
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
          @ast.Expr::Splits(s)
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
              @ast.Expr::Sub(pattern, replacement)
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
              @ast.Expr::GSub(pattern, replacement)
            }
            _ => raise InvalidSyntax("gsub expects string replacement")
          }
        }
        _ => raise InvalidSyntax("gsub expects string pattern")
      }
    }
    _ =>
      // Check if it's a function call with parentheses
      if self.current() == Some(TLParen) {
        self.advance()
        let args : Array[@ast.Expr] = []
        if not(self.current() == Some(TRParen)) {
          args.push(self.parse_pipe())
          while self.consume(TSemicolon) {
            args.push(self.parse_pipe())
          }
        }
        self.expect(TRParen)
        @ast.Expr::FunctionCall(name, args)
      } else {
        // Zero-argument function call
        @ast.Expr::FunctionCall(name, [])
      }
  }
}
