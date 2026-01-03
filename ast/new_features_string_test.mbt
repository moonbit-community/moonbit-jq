///|
test "split function" {
  let result = run_jq(".name | split(\",\")", "{\"name\":\"a,b,c\"}")
  inspect(
    result,
    content="Ok([Array([String(\"a\"), String(\"b\"), String(\"c\")])])",
  )
}

///|
test "join function" {
  let result = run_jq(".items | join(\",\")", "{\"items\":[\"a\",\"b\",\"c\"]}")
  inspect(
    result,
    content=(
      #|Ok([String("a,b,c")])
    ),
  )
}

///|
test "contains function" {
  let result = run_jq(
    ".text | contains(\"hello\")", "{\"text\":\"hello world\"}",
  )
  inspect(result, content="Ok([True])")
}

///|
test "startswith function" {
  let result = run_jq(
    ".text | startswith(\"hello\")", "{\"text\":\"hello world\"}",
  )
  inspect(result, content="Ok([True])")
}

///|
test "endswith function" {
  let result = run_jq(
    ".text | endswith(\"world\")", "{\"text\":\"hello world\"}",
  )
  inspect(result, content="Ok([True])")
}
