///|
fn lex_err(query : String) -> Bool {
  try @parser.lex(query) catch {
    _ => true
  } noraise {
    _ => false
  }
}

///|
test "coverage: peek at end of input" {
  // Triggers lexer.peek() at end for '-' number lookahead.
  debug_inspect(@parser.lex("-"), content="[TMinus, TEof]")
}

///|
test "coverage: string escape sequences" {
  let query : Array[String] = [
    "\"\\n\"", "\"\\r\"", "\"\\t\"", "\"\\b\"", "\"\\/\"", "\"\\\"\"", "\"\\\\\"",
  ]
  let expected : Array[String] = ["\n", "\r", "\t", "\b", "/", "\"", "\\"]
  for i in 0..<query.length() {
    let tokens = @parser.lex(query[i])
    match tokens[1] {
      TStringText(s) => assert_true(s == expected[i])
      _ => assert_true(false)
    }
  }
}

///|
test "coverage: string lexer preserves unicode text" {
  let tokens = @parser.lex("\"hé 世界\"")
  match tokens[1] {
    TStringText(s) => assert_true(s == "hé 世界")
    _ => assert_true(false)
  }
}

///|
test "coverage: interpolation lexer handles nested parens and strings" {
  // Includes nested parentheses and a nested string with an escaped quote.
  let query : String =
    #|"x \((1 + (2)) | "a\"b") y"
  let tokens = @parser.lex(query)
  assert_true(tokens[0] is TStringStart)
  assert_true(tokens.iter().any(t => t is TInterpolationStart))
  assert_true(tokens.iter().any(t => t is TInterpolationEnd))
}

///|
test "coverage: lex errors for unexpected characters" {
  assert_true(lex_err("!"))
  assert_true(lex_err("~"))
}

///|
test "coverage: unterminated strings" {
  assert_true(lex_err("\"abc"))
  assert_true(lex_err("\"\\("))
  assert_true(lex_err("\"\\(\""))
}

///|
test "coverage: unterminated escape at end" {
  let sb = StringBuilder()
  sb..write_char('"').write_char('\\')
  assert_true(lex_err(sb.to_string()))
}
