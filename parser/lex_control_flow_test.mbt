///|
/// Lexing control flow expressions
test "lex: if-then-else" {
  let tokens = @parser.lex("if .x > 0 then .x else 0 end")
  debug_inspect(
    tokens,
    content=(
      #|[
      #|  TIf,
      #|  TField("x"),
      #|  TGt,
      #|  TNumber(0),
      #|  TThen,
      #|  TField("x"),
      #|  TElse,
      #|  TNumber(0),
      #|  TEnd,
      #|  TEof,
      #|]
    ),
  )
}

///|
test "lex: try-catch" {
  let tokens = @parser.lex("try .foo catch \"error\"")
  debug_inspect(
    tokens,
    content=(
      #|[
      #|  TTry,
      #|  TField("foo"),
      #|  TCatch,
      #|  TStringStart,
      #|  TStringText("error"),
      #|  TStringEnd,
      #|  TEof,
      #|]
    ),
  )
}
