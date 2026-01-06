///|
test "round function" {
  let result = run_jq("round", "3.7")
  inspect(result, content="Ok([Number(4)])")
}

///|
test "ceil function" {
  let result = run_jq("ceil", "3.2")
  inspect(result, content="Ok([Number(4)])")
}

///|
test "abs function" {
  let result = run_jq("abs", "-5")
  inspect(result, content="Ok([Number(5)])")
}
