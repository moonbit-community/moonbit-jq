///|
/// A token with its location in the original query.
pub(all) struct LocatedToken {
  token : Token
  span : @ast.Span
} derive(Eq, Debug)

///|
/// Tokenize a complete query, retaining UTF-16 source offsets.
pub fn lex_spanned(input : String) -> Array[LocatedToken] raise LexError {
  let lexer = Lexer::new(input)
  lexer.run()
  lexer.tokens.mapi((i, token) => { token, span: lexer.spans[i], })
}

///|
/// Tokenize a query. Use `lex_spanned` when diagnostics need locations.
pub fn lex(input : String) -> Array[Token] raise LexError {
  lex_spanned(input).map(t => t.token)
}

///|
fn Lexer::run(self : Lexer) -> Unit raise LexError {
  while true {
    self.start = self.pos
    if self.modes.last() is Some(StringMode(start)) {
      self.lex_string_text(start)
      continue
    }
    self.skip_whitespace()
    self.start = self.pos
    match self.current() {
      None => {
        if self.modes.length() != 1 {
          let expected = match self.modes.last() {
            Some(Code(token)) => token.to_string()
            _ => "string"
          }
          raise UnterminatedRegion(self.pos, expected)
        }
        break
      }
      Some('#') => self.skip_comment()
      Some('"') => self.lex_string()
      Some('$') => self.lex_variable()
      Some('@') => self.lex_format()
      Some(c) if is_digit(c) ||
        (c == '.' && self.peek().map(is_digit).unwrap_or(false)) =>
        self.lex_number()
      Some(c) if is_alpha(c) => self.lex_identifier()
      Some('(') | Some('[') | Some('{') => {
        let c = self.current().unwrap()
        self.modes.push(
          Code(
            match c {
              '(' => TRParen
              '[' => TRBracket
              _ => TRBrace
            },
          ),
        )
        self.lex_symbol(c)
      }
      Some(')') | Some(']') | Some('}') => {
        let c = self.current().unwrap()
        let closing = match c {
          ')' => TRParen
          ']' => TRBracket
          _ => TRBrace
        }
        match self.modes.last() {
          Some(Code(TInterpolationEnd)) if c == ')' => {
            self.modes.pop() |> ignore
            self.advance()
            self.add_token(TInterpolationEnd)
          }
          Some(Code(expected)) if expected == closing => {
            self.modes.pop() |> ignore
            self.lex_symbol(c)
          }
          _ => raise UnexpectedChar(self.pos, c)
        }
      }
      Some(c) => self.lex_symbol(c)
    }
  }
  self.start = self.pos
  self.add_token(TEof)
}

///|
pub extend LocatedToken with Eq::{not_equal, equal}

///|
pub extend LocatedToken with @debug.Debug::{to_repr}
