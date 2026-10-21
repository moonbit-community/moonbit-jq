///|
test "round function" {
  let result = run_jq("round", "3.7")
  debug_inspect(result, content="Ok([Number(4)])")
}

///|
test "ceil function" {
  let result = run_jq("ceil", "3.2")
  debug_inspect(result, content="Ok([Number(4)])")
}

///|
test "abs function" {
  let result = run_jq("abs", "-5")
  debug_inspect(result, content="Ok([Number(5)])")
}
