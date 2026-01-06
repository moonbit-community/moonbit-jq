///|
/// Test error handling
test "panic unexpected token" {
  inspect(
    try? @parser.parse("@"),
    content=(
      #|Err(UnexpectedToken(TAt, "expression"))
    ),
  )
}

///|
test "panic unexpected end" {
  inspect(
    try? @parser.parse("if .x then"),
    content=(
      #|Err(UnexpectedEnd("TElse"))
    ),
  )
}
