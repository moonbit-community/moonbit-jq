///|
test "frontend: locations count UTF-16 in the original query" {
  let tokens = @parser.lex_spanned(".and \"😀\\(1)\"")
  assert_true(tokens[0].token is TField("and"))
  assert_eq(tokens[0].span.start, 0)
  assert_eq(tokens[0].span.end, 4)
  assert_true(tokens[2].token is TStringText("😀"))
  assert_eq(tokens[2].span.start, 6)
  assert_eq(tokens[2].span.end, 8)
  assert_true(tokens[3].token is TInterpolationStart)
  assert_eq(tokens[3].span.start, 8)
  assert_eq(tokens[3].span.end, 10)
}

///|
test "frontend: interpolation diagnostics retain the outer source offset" {
  try @parser.parse("\"😀 \\(1 2)\"") catch {
    @parser.Diagnostic(_, span) => {
      assert_eq(span.start, 8)
      assert_eq(span.end, 9)
    }
    _ => fail("expected a located parser diagnostic")
  } noraise {
    _ => fail("trailing interpolation tokens must fail")
  }
}

///|
test "frontend: intermediate operations retain their source regions" {
  let expr = @parser.parse("1 + 2 + 3")
  guard expr is Located(whole, Operation(Located(left, _), _, _)) else {
    fail("expected located intermediate operation")
  }
  assert_eq(whole.start, 0)
  assert_eq(whole.end, 9)
  assert_eq(left.start, 0)
  assert_eq(left.end, 5)
}

///|
test "frontend: implicit navigation nodes retain source regions" {
  let expr = @parser.parse(".a[]")
  guard expr
    is Located(whole, Pipe(Located(field, Key("a")), Located(each, Index([])))) else {
    fail("all navigation nodes must be located")
  }
  assert_eq(whole.start, 0)
  assert_eq(whole.end, 4)
  assert_eq(field.start, 0)
  assert_eq(field.end, 2)
  assert_eq(each.start, 2)
  assert_eq(each.end, 4)
}

///|
test "frontend: quoted postfix fields are located subscripts" {
  let source = ".a.\"😀\\(.k)\""
  let expr = @parser.parse(source)
  guard expr
    is Located(whole, Subscript(Located(base, Key("a")), Located(key, _))) else {
    fail("expected a subscript with a separately located key")
  }
  assert_eq(whole.start, 0)
  assert_eq(whole.end, source.length())
  assert_eq(base.start, 0)
  assert_eq(base.end, 2)
  assert_eq(key.start, 3)
  assert_eq(key.end, source.length())
}
