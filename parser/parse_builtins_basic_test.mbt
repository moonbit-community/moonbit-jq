///|
/// Test parsing basic built-in functions
test "parse length" {
  json_inspect(@parser.parse("length"), content="Length")
}

///|
test "parse keys" {
  json_inspect(@parser.parse("keys"), content="Keys")
}

///|
test "parse type" {
  json_inspect(@parser.parse("type"), content="Type")
}
