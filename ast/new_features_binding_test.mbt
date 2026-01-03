///|
test "reduce expression" {
  let result = run_jq("reduce .[] as $x (0; . + $x)", "[1,2,3,4,5]")
  inspect(
    result,
    content=(
      #|Ok([Number(15)])
    ),
  )
}

///|
test "as expression" {
  let result = run_jq(".a as $x | .b + $x", "{\"a\":10,\"b\":5}")
  inspect(result, content="Ok([Number(15)])")
}
