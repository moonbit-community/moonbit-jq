///|
test "missing: ltrimstr" {
  assert_reference_query(
    ".text | ltrimstr(\"hello \")", "{\"text\":\"hello world\"}", "[\"world\"]",
    0,
  )
}

///|
test "missing: rtrimstr" {
  assert_reference_query(
    ".text | rtrimstr(\" world\")", "{\"text\":\"hello world\"}", "[\"hello\"]",
    0,
  )
}

///|
test "missing: ascii_upcase" {
  assert_reference_query(
    ".text | ascii_upcase", "{\"text\":\"hello\"}", "[\"HELLO\"]", 0,
  )
}

///|
test "missing: ascii_downcase" {
  assert_reference_query(
    ".text | ascii_downcase", "{\"text\":\"HELLO\"}", "[\"hello\"]", 0,
  )
}

///|
test "missing: string interpolation" {
  assert_reference_query(
    "\"Hello \\(.name)\"", "{\"name\":\"World\"}", "[\"Hello World\"]", 0,
  )
}
