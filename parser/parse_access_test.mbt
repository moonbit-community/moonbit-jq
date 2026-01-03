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

///|
/// Test parsing optional operator

test "parse optional" {
  @json.inspect(@parser.parse(".foo?"), content=["Optional", ["Key", "foo"]])
}

///|
/// Test parsing variables

test "parse variable" {
  @json.inspect(@parser.parse("$foo"), content=["Variable", "foo"])
}
