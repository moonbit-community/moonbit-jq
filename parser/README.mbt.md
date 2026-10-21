# Query frontend

`parse(source)` returns a syntax AST and requires EOF after the complete query.
Each interpolation and bracketed region must consume its own closing delimiter.
An incomplete postfix such as `.a.` is an error; `.` and `1.` remain valid.

`lex(source)` returns tokens ending in `TEof`. `lex_spanned(source)` also returns
half-open UTF-16 spans into the original source. `.and` is a single `TField("and")`
token, while `. and .line` includes the standalone logical operator. Object keys
use the same keyword spelling table as the lexer.

Strings use `TStringStart`, `TStringText`, `TInterpolationStart`,
`TInterpolationEnd`, and `TStringEnd`. The lexer state stack handles nested
strings, brackets, interpolation, escapes, and comments without extracting or
reparsing source substrings.

AST nodes retain source spans through `Located`. Function calls retain a name and
argument expressions; binding, arity checks, and argument consumption belong to
`runtime.compile`. The parser does not have builtin-specific argument parsers.

```mbt check
///|
test "readme: located fields" {
  let tokens = @parser.lex_spanned(".end")
  assert_true(tokens[0].token is TField("end"))
  assert_eq(tokens[0].span.start, 0)
  assert_eq(tokens[0].span.end, 4)
}
```

Lexical failures carry a source offset in `LexError`. Public parsing wraps syntax
failures as `ParseError::Diagnostic(message, span)`. The complete public token and
AST interfaces are generated in `pkg.generated.mbti` and `../ast/pkg.generated.mbti`.
