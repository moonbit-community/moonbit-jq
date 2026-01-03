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
      Some(c) => lexer.lex_symbol(c)
    }
  }
  lexer.add_token(TEof)
  lexer.tokens
}
