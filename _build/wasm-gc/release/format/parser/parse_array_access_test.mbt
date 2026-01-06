///|
/// Test parsing array operations
test "parse array index" {
  @json.inspect(@parser.parse(".[0]"), content=[
    "Pipe",
    "Identity",
    ["Index", [0]],
  ])
}

///|
test "parse multiple indices" {
  @json.inspect(@parser.parse(".[0,2,4]"), content=[
    "Pipe",
    "Identity",
    ["Index", [0, 2, 4]],
  ])
}

///|
test "parse array iterator" {
  @json.inspect(@parser.parse(".[]"), content=[
    "Pipe",
    "Identity",
    ["Index", []],
  ])
}

///|
test "parse array slice" {
  @json.inspect(@parser.parse(".[2:4]"), content=[
    "Pipe",
    "Identity",
    ["Slice", [2], [4]],
  ])
}

///|
test "parse open-ended slices" {
  @json.inspect(@parser.parse(".[2:]"), content=[
    "Pipe",
    "Identity",
    ["Slice", [2], null],
  ])
  @json.inspect(@parser.parse(".[:4]"), content=[
    "Pipe",
    "Identity",
    ["Slice", null, [4]],
  ])
}
