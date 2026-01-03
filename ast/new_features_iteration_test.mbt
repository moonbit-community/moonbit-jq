///|
test "range function" {
  let result = run_jq("range(5)", "null")
  inspect(
    result,
    content="Ok([Number(0), Number(1), Number(2), Number(3), Number(4)])",
  )
}

///|
test "first function" {
  let result = run_jq("first", "[1,2,3]")
  inspect(result, content="Ok([Number(1)])")
}

///|
test "last function" {
  let result = run_jq("last", "[1,2,3]")
  inspect(result, content="Ok([Number(3)])")
}
