///|
test "has function" {
  let result = run_jq("has(\"name\")", "{\"name\":\"John\",\"age\":30}")
  inspect(result, content="Ok([True])")
  let result2 = run_jq("has(\"missing\")", "{\"name\":\"John\"}")
  inspect(result2, content="Ok([False])")
}

///|
test "to_entries function" {
  let result = run_jq("to_entries", "{\"a\":1,\"b\":2}")
  inspect(
    result,
    content=(
      #|Ok([Array([Object({"key": String("a"), "value": Number(1)}), Object({"key": String("b"), "value": Number(2)})])])
    ),
  )
}

///|
test "from_entries function" {
  let result = run_jq(
    "from_entries", "[{\"key\":\"a\",\"value\":1},{\"key\":\"b\",\"value\":2}]",
  )
  inspect(
    result,
    content=(
      #|Ok([Object({"a": Number(1), "b": Number(2)})])
    ),
  )
}
