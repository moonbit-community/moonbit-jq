///|
/// Corner case tests for string/array conversion

///|
test "corner: explode converts string to codepoints" {
  assert_reference_query(
    "explode", "\"Hello\"", "[[72, 101, 108, 108, 111]]", 0,
  )
}

///|
test "corner: implode converts codepoints to string" {
  assert_reference_query("implode", "[72,101,108,108,111]", "[\"Hello\"]", 0)
}

///|
test "corner: explode with unicode" {
  assert_reference_query("explode", "\"世界\"", "[[19990, 30028]]", 0)
}

///|
test "corner: implode with unicode codepoints" {
  assert_reference_query("implode", "[19990,30028]", "[\"世界\"]", 0)
}
