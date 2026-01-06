///|
/// Test parsing field access
test "parse field access" {
  @json.inspect(@parser.parse(".foo"), content=["Key", "foo"])
}

///|
test "parse nested field access" {
  @json.inspect(@parser.parse(".foo.bar"), content=[
    "Pipe",
    ["Key", "foo"],
    ["Key", "bar"],
  ])
}
