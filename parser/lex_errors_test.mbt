///|
/// Lexing error handling
test "lex: error - unterminated string" {
  try @parser.lex("\"hello") catch {
    UnterminatedString(_) => debug_inspect(true, content="true")
    _ => fail("expected UnterminatedString error")
  } noraise {
    _ => fail("expected UnterminatedString error")
  }
}

///|
test "lex: error - invalid escape" {
  try @parser.lex("\"hello\\x\"") catch {
    InvalidEscape(_, _) => debug_inspect(true, content="true")
    _ => fail("expected InvalidEscape error")
  } noraise {
    _ => fail("expected InvalidEscape error")
  }
}

///|
test "lex: error - unexpected character" {
  try @parser.lex("@") catch {
    UnexpectedChar(_, _) => fail("did not expect UnexpectedChar error")
    _ => debug_inspect(false, content="false")
  } noraise {
    _ => debug_inspect(false, content="false")
  }
}
