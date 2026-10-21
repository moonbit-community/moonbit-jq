///|
fn reduce_tokens() -> Array[Token] {
  [
    TReduce,
    TDot,
    TAs,
    TVariable("x"),
    TLParen,
    TNumber(0.0),
    TSemicolon,
    TDot,
    TRParen,
  ]
}

///|
fn foreach_tokens(with_extract : Bool) -> Array[Token] {
  let tokens = [
    TForeach,
    TDot,
    TAs,
    TVariable("x"),
    TLParen,
    TNumber(0.0),
    TSemicolon,
    TDot,
  ]
  if with_extract {
    tokens.push(TSemicolon)
    tokens.push(TDot)
  }
  tokens.push(TRParen)
  tokens
}

///|
test "wb: parser none branches" {
  let parser = Parser::new([])
  assert_true(parser.current() is None)
  assert_true(!parser.check(TDot))
  try parser.expect(TDot) catch {
    _ => ()
  } noraise {
    _ => fail("expected parser.expect error")
  }
  try parser.parse_primary() catch {
    _ => ()
  } noraise {
    _ => fail("expected parser.parse_primary error")
  }
}

///|
test "wb: parse_builtin not" {
  let parser = Parser::new([])
  let expr = parser.parse_builtin("not")
  assert_true(expr is FunctionCall("not", []))
}

///|
test "wb: parse_builtin reduce success" {
  let parser = Parser::new(reduce_tokens())
  let expr = parser.parse_reduce()
  assert_true(expr is Reduce(_, _, _, _))
}

///|
test "wb: parse_builtin reduce missing variable" {
  let parser = Parser::new([TReduce, TDot, TAs, TIdentifier("x")])
  try parser.parse_reduce() catch {
    _ => ()
  } noraise {
    _ => fail("expected reduce parse error")
  }
}

///|
test "wb: parse_builtin foreach success with extract" {
  let parser = Parser::new(foreach_tokens(true))
  let expr = parser.parse_foreach()
  assert_true(expr is Foreach(_, _, _, _, Some(_)))
}

///|
test "wb: parse_builtin foreach success without extract" {
  let parser = Parser::new(foreach_tokens(false))
  let expr = parser.parse_foreach()
  assert_true(expr is Foreach(_, _, _, _, None))
}

///|
test "wb: parse_builtin foreach missing variable" {
  let parser = Parser::new([TForeach, TDot, TAs, TIdentifier("x")])
  try parser.parse_foreach() catch {
    _ => ()
  } noraise {
    _ => fail("expected foreach parse error")
  }
}
