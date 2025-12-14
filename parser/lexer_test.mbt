///|
test "lex: empty input" {
  let tokens = @parser.lex("")
  inspect(tokens, content="[TEof]")
}

///|
test "lex: dot operator" {
  let tokens = @parser.lex(".")
  inspect(tokens, content="[TDot, TEof]")
}

///|
test "lex: field access" {
  let tokens = @parser.lex(".foo")
  inspect(tokens, content="[TDot, TIdentifier(\"foo\"), TEof]")
}

///|
test "lex: pipe operator" {
  let tokens = @parser.lex(".foo | .bar")
  inspect(
    tokens,
    content="[TDot, TIdentifier(\"foo\"), TPipe, TDot, TIdentifier(\"bar\"), TEof]",
  )
}

///|
test "lex: array index" {
  let tokens = @parser.lex(".[0]")
  inspect(tokens, content="[TDot, TLBracket, TNumber(0), TRBracket, TEof]")
}

///|
test "lex: array iterator" {
  let tokens = @parser.lex(".[]")
  inspect(tokens, content="[TDot, TLBracket, TRBracket, TEof]")
}

///|
test "lex: numbers" {
  let tokens = @parser.lex("123 45.67 -89 -0.5")
  inspect(
    tokens,
    content="[TNumber(123), TNumber(45.67), TNumber(-89), TNumber(-0.5), TEof]",
  )
}

///|
test "lex: string literals" {
  let tokens = @parser.lex("\"hello\" \"world\"")
  inspect(tokens, content="[TString(\"hello\"), TString(\"world\"), TEof]")
}

///|
test "lex: string escapes" {
  let tokens = @parser.lex("\"hello\\nworld\" \"tab\\there\" \"quote\\\"test\"")
  inspect(
    tokens,
    content="[TString(\"hello\\nworld\"), TString(\"tab\\there\"), TString(\"quote\\\"test\"), TEof]",
  )
}

///|
test "lex: boolean and null literals" {
  let tokens = @parser.lex("true false null")
  inspect(tokens, content="[TTrue, TFalse, TNull, TEof]")
}

///|
test "lex: keywords" {
  let tokens = @parser.lex("if then else end and or not")
  inspect(tokens, content="[TIf, TThen, TElse, TEnd, TAnd, TOr, TNot, TEof]")
}

///|
test "lex: arithmetic operators" {
  let tokens = @parser.lex("+ - * / %")
  inspect(tokens, content="[TPlus, TMinus, TStar, TSlash, TPercent, TEof]")
}

///|
test "lex: comparison operators" {
  let tokens = @parser.lex("== != < <= > >=")
  inspect(tokens, content="[TEq, TNeq, TLt, TLe, TGt, TGe, TEof]")
}

///|
test "lex: comma and semicolon" {
  let tokens = @parser.lex(", ;")
  inspect(tokens, content="[TComma, TSemicolon, TEof]")
}

///|
test "lex: brackets and braces" {
  let tokens = @parser.lex("( ) [ ] { }")
  inspect(
    tokens,
    content="[TLParen, TRParen, TLBracket, TRBracket, TLBrace, TRBrace, TEof]",
  )
}

///|
test "lex: variable" {
  let tokens = @parser.lex("$foo $bar123")
  inspect(tokens, content="[TVariable(\"foo\"), TVariable(\"bar123\"), TEof]")
}

///|
test "lex: assignment operators" {
  let tokens = @parser.lex("= |= //")
  inspect(tokens, content="[TAssign, TUpdate, TAlternative, TEof]")
}

///|
test "lex: dot dot" {
  let tokens = @parser.lex("..")
  inspect(tokens, content="[TDotDot, TEof]")
}

///|
test "lex: comment" {
  let tokens = @parser.lex("# comment\n.foo")
  inspect(tokens, content="[TDot, TIdentifier(\"foo\"), TEof]")
}

///|
test "lex: complex expression" {
  let tokens = @parser.lex(".foo | map(.bar) | select(. > 10)")
  inspect(
    tokens,
    content=(
      #|[TDot, TIdentifier("foo"), TPipe, TIdentifier("map"), TLParen, TDot, TIdentifier("bar"), TRParen, TPipe, TIdentifier("select"), TLParen, TDot, TGt, TNumber(10), TRParen, TEof]
    ),
  )
}

///|
test "lex: object construction" {
  let tokens = @parser.lex("{foo: .bar, baz: 42}")
  inspect(
    tokens,
    content=(
      #|[TLBrace, TIdentifier("foo"), TColon, TDot, TIdentifier("bar"), TComma, TIdentifier("baz"), TColon, TNumber(42), TRBrace, TEof]
    ),
  )
}

///|
test "lex: array construction" {
  let tokens = @parser.lex("[1, 2, 3]")
  inspect(
    tokens,
    content="[TLBracket, TNumber(1), TComma, TNumber(2), TComma, TNumber(3), TRBracket, TEof]",
  )
}

///|
test "lex: if-then-else" {
  let tokens = @parser.lex("if .x > 0 then .x else 0 end")
  inspect(
    tokens,
    content=(
      #|[TIf, TDot, TIdentifier("x"), TGt, TNumber(0), TThen, TDot, TIdentifier("x"), TElse, TNumber(0), TEnd, TEof]
    ),
  )
}

///|
test "lex: as expression" {
  let tokens = @parser.lex(". as $x | $x + 1")
  inspect(
    tokens,
    content=(
      #|[TDot, TAs, TVariable("x"), TPipe, TVariable("x"), TPlus, TNumber(1), TEof]
    ),
  )
}

///|
test "lex: reduce expression" {
  let tokens = @parser.lex("reduce .[] as $x (0; . + $x)")
  inspect(
    tokens,
    content=(
      #|[TReduce, TDot, TLBracket, TRBracket, TAs, TVariable("x"), TLParen, TNumber(0), TSemicolon, TDot, TPlus, TVariable("x"), TRParen, TEof]
    ),
  )
}

///|
test "lex: try-catch" {
  let tokens = @parser.lex("try .foo catch \"error\"")
  inspect(
    tokens,
    content="[TTry, TDot, TIdentifier(\"foo\"), TCatch, TString(\"error\"), TEof]",
  )
}

///|
test "lex: optional operator" {
  let tokens = @parser.lex(".foo?")
  inspect(tokens, content="[TDot, TIdentifier(\"foo\"), TQuestion, TEof]")
}

///|
test "lex: whitespace handling" {
  let tokens = @parser.lex("  .foo  \n  |  \t  .bar  ")
  inspect(
    tokens,
    content="[TDot, TIdentifier(\"foo\"), TPipe, TDot, TIdentifier(\"bar\"), TEof]",
  )
}

///|
test "lex: error - unterminated string" {
  let result = try? @parser.lex("\"hello")
  match result {
    Err(@parser.LexError::UnterminatedString(_)) =>
      inspect(true, content="true")
    _ => inspect(false, content="should be UnterminatedString error")
  }
}

///|
test "lex: error - invalid escape" {
  let result = try? @parser.lex("\"hello\\x\"")
  match result {
    Err(@parser.LexError::InvalidEscape(_, _)) => inspect(true, content="true")
    _ => inspect(false, content="should be InvalidEscape error")
  }
}

///|
test "lex: error - unexpected character" {
  let result = try? @parser.lex("@")
  match result {
    Err(@parser.LexError::UnexpectedChar(_, _)) => inspect(true, content="true")
    _ => inspect(false, content="false")
  }
}
