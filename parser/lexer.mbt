///|
/// Main lexing function
pub fn lex(input : String) -> Array[Token] raise LexError {
  let lexer = Lexer::new(input)
  while true {
    lexer.skip_whitespace()
    match lexer.current() {
      None => break
      Some('#') => lexer.skip_comment()
      Some('"') => lexer.lex_string()
      Some('$') => lexer.lex_variable()
      Some('@') => lexer.lex_format()
      Some(c) if is_digit(c) ||
        (c == '-' && lexer.peek().map(is_digit).unwrap_or(false)) =>
        lexer.lex_number()
      Some(c) if is_alpha(c) => lexer.lex_identifier()
      Some(c) =>
        match c {
          '.' => {
            lexer.advance()
            if lexer.current() == Some('.') {
              lexer.advance()
              lexer.add_token(TDotDot)
            } else {
              lexer.add_token(TDot)
            }
          }
          '|' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TUpdate)
            } else {
              lexer.add_token(TPipe)
            }
          }
          '/' => {
            lexer.advance()
            if lexer.current() == Some('/') {
              lexer.advance()
              if lexer.current() == Some('=') {
                lexer.advance()
                lexer.add_token(TAltAssign)
              } else {
                lexer.add_token(TAlternative)
              }
            } else if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TDivAssign)
            } else {
              lexer.add_token(TSlash)
            }
          }
          '=' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TEq)
            } else {
              lexer.add_token(TAssign)
            }
          }
          '!' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TNeq)
            } else {
              raise UnexpectedChar(lexer.pos, c)
            }
          }
          '<' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TLe)
            } else {
              lexer.add_token(TLt)
            }
          }
          '>' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TGe)
            } else {
              lexer.add_token(TGt)
            }
          }
          ',' => {
            lexer.advance()
            lexer.add_token(TComma)
          }
          ':' => {
            lexer.advance()
            lexer.add_token(TColon)
          }
          ';' => {
            lexer.advance()
            lexer.add_token(TSemicolon)
          }
          '?' => {
            lexer.advance()
            lexer.add_token(TQuestion)
          }
          '(' => {
            lexer.advance()
            lexer.add_token(TLParen)
          }
          ')' => {
            lexer.advance()
            lexer.add_token(TRParen)
          }
          '[' => {
            lexer.advance()
            lexer.add_token(TLBracket)
          }
          ']' => {
            lexer.advance()
            lexer.add_token(TRBracket)
          }
          '{' => {
            lexer.advance()
            lexer.add_token(TLBrace)
          }
          '}' => {
            lexer.advance()
            lexer.add_token(TRBrace)
          }
          '+' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TAddAssign)
            } else {
              lexer.add_token(TPlus)
            }
          }
          '-' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TSubAssign)
            } else {
              lexer.add_token(TMinus)
            }
          }
          '*' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TMulAssign)
            } else {
              lexer.add_token(TStar)
            }
          }
          '%' => {
            lexer.advance()
            if lexer.current() == Some('=') {
              lexer.advance()
              lexer.add_token(TModAssign)
            } else {
              lexer.add_token(TPercent)
            }
          }
          _ => raise UnexpectedChar(lexer.pos, c)
        }
    }
  }
  lexer.add_token(TEof)
  lexer.tokens
}
