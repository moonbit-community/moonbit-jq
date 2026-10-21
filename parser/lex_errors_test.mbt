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
    UnexpectedChar(_, _) => ()
    _ => fail("a format prefix needs a name")
  } noraise {
    _ => fail("a format prefix needs a name")
  }
}

///|
test "lex: error - short unicode escape" {
  try @parser.lex("\"\\u12\"") catch {
    InvalidEscape(_, _) => ()
    _ => fail("expected InvalidEscape error")
  } noraise {
    _ => fail("expected InvalidEscape error")
  }
}
