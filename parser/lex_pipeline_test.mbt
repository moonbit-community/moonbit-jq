///|
/// Lexing pipeline expressions
test "lex: complex expression" {
  let tokens = @parser.lex(".foo | map(.bar) | select(. > 10)")
  debug_inspect(
    tokens,
    content=(
      #|[
      #|  TField("foo"),
      #|  TPipe,
      #|  TIdentifier("map"),
      #|  TLParen,
      #|  TField("bar"),
      #|  TRParen,
      #|  TPipe,
      #|  TIdentifier("select"),
      #|  TLParen,
      #|  TDot,
      #|  TGt,
      #|  TNumber(10),
      #|  TRParen,
      #|  TEof,
      #|]
    ),
  )
}
