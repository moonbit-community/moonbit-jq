///|
/// Test error handling
test "panic unexpected token" {
  debug_inspect(
    try? @parser.parse("@"),
    content=(
      #|Err(UnexpectedToken(TAt, "expression"))
    ),
  )
}

///|
test "panic unexpected end" {
  debug_inspect(
    try? @parser.parse("if .x then"),
    content=(
      #|Err(UnexpectedEnd("TElse"))
    ),
  )
}
