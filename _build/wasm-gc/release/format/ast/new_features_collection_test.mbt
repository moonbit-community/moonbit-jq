///|
test "sort_by function" {
  let result = run_jq(
    "sort_by(.age)", "[{\"name\":\"Bob\",\"age\":30},{\"name\":\"Alice\",\"age\":25}]",
  )
  inspect(
    result,
    content=(
      #|Ok([Array([Object({"name": String("Alice"), "age": Number(25)}), Object({"name": String("Bob"), "age": Number(30)})])])
    ),
  )
}

///|
test "group_by function" {
  let result = run_jq(
    "group_by(.type)", "[{\"name\":\"a\",\"type\":\"X\"},{\"name\":\"b\",\"type\":\"Y\"},{\"name\":\"c\",\"type\":\"X\"}]",
  )
  inspect(
    result,
    content=(
      #|Ok([Array([Array([Object({"name": String("a"), "type": String("X")}), Object({"name": String("c"), "type": String("X")})]), Array([Object({"name": String("b"), "type": String("Y")})])])])
    ),
  )
}
