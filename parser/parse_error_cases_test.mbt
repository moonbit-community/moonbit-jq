///|
/// Test error handling
test "panic unexpected token" {
  try @parser.parse("@") catch {
    @parser.UnexpectedToken("TAt", "expression") =>
      debug_inspect(true, content="true")
    _ => fail("expected UnexpectedToken(TAt, \"expression\")")
  } noraise {
    _ => fail("expected UnexpectedToken(TAt, \"expression\")")
  }
}

///|
test "panic unexpected end" {
  try @parser.parse("if .x then") catch {
    @parser.UnexpectedEnd("TElse") => debug_inspect(true, content="true")
    _ => fail("expected UnexpectedEnd(\"TElse\")")
  } noraise {
    _ => fail("expected UnexpectedEnd(\"TElse\")")
  }
}
