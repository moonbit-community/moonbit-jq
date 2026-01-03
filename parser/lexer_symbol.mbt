///|
/// Lex operators and punctuation
fn Lexer::lex_symbol(self : Lexer, c : Char) -> Unit raise LexError {
  match c {
    '.' => {
      self.advance()
      if self.current() == Some('.') {
        self.advance()
        self.add_token(TDotDot)
      } else {
        self.add_token(TDot)
      }
    }
    '|' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TUpdate)
      } else {
        self.add_token(TPipe)
      }
    }
    '/' => {
      self.advance()
      if self.current() == Some('/') {
        self.advance()
        if self.current() == Some('=') {
          self.advance()
          self.add_token(TAltAssign)
        } else {
          self.add_token(TAlternative)
        }
      } else if self.current() == Some('=') {
        self.advance()
        self.add_token(TDivAssign)
      } else {
        self.add_token(TSlash)
      }
    }
    '=' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TEq)
      } else {
        self.add_token(TAssign)
      }
    }
    '!' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TNeq)
      } else {
        raise UnexpectedChar(self.pos, c)
      }
    }
    '<' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TLe)
      } else {
        self.add_token(TLt)
      }
    }
    '>' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TGe)
      } else {
        self.add_token(TGt)
      }
    }
    ',' => {
      self.advance()
      self.add_token(TComma)
    }
    ':' => {
      self.advance()
      self.add_token(TColon)
    }
    ';' => {
      self.advance()
      self.add_token(TSemicolon)
    }
    '?' => {
      self.advance()
      self.add_token(TQuestion)
    }
    '(' => {
      self.advance()
      self.add_token(TLParen)
    }
    ')' => {
      self.advance()
      self.add_token(TRParen)
    }
    '[' => {
      self.advance()
      self.add_token(TLBracket)
    }
    ']' => {
      self.advance()
      self.add_token(TRBracket)
    }
    '{' => {
      self.advance()
      self.add_token(TLBrace)
    }
    '}' => {
      self.advance()
      self.add_token(TRBrace)
    }
    '+' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TAddAssign)
      } else {
        self.add_token(TPlus)
      }
    }
    '-' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TSubAssign)
      } else {
        self.add_token(TMinus)
      }
    }
    '*' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TMulAssign)
      } else {
        self.add_token(TStar)
      }
    }
    '%' => {
      self.advance()
      if self.current() == Some('=') {
        self.advance()
        self.add_token(TModAssign)
      } else {
        self.add_token(TPercent)
      }
    }
    _ => raise UnexpectedChar(self.pos, c)
  }
}
