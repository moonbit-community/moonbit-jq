///|
/// Test basic identity and field access
test "integration: basic queries" {
  @json.inspect(jq(".", "42"), content=[42])
  @json.inspect(jq(".foo", "{\"foo\": \"bar\"}"), content=["bar"])
  @json.inspect(jq(".a.b", "{\"a\": {\"b\": 123}}"), content=[123])
}

///|
/// Test array operations
test "integration: array operations" {
  @json.inspect(jq(".[]", "[1,2,3]"), content=[1, 2, 3])
  @json.inspect(jq(".[1]", "[10,20,30]"), content=[20])
  @json.inspect(jq(".[-1]", "[10,20,30]"), content=[30])
  @json.inspect(jq(".[1:3]", "[1,2,3,4,5]"), content=[[2, 3]])
}

///|
/// Test string operations
test "integration: strings" {
  @json.inspect(jq("\"hello\" + \" \" + \"world\"", "null"), content=[
    "hello world",
  ])
  @json.inspect(
    jq(".first + .last", "{\"first\": \"Hello\", \"last\": \" MoonBit\"}"),
    content=["Hello MoonBit"],
  )
}
