///|
/// Corner case tests for ASCII casing

///|
test "corner: ascii_downcase preserves non-ASCII" {
  assert_reference_query("ascii_downcase", "\"CAFÉ\"", "[\"cafÉ\"]", 0)
}

///|
test "corner: ascii_upcase preserves non-ASCII" {
  assert_reference_query("ascii_upcase", "\"café\"", "[\"CAFé\"]", 0)
}
