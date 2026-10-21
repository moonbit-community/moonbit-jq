///|
/// Corner case tests for splits

///|
test "corner: splits with single delimiter" {
  assert_reference_query(
    "[splits(\",\")]", "\"a,b,c,d\"", "[[\"a\", \"b\", \"c\", \"d\"]]", 0,
  )
}

///|
test "corner: splits with empty result" {
  assert_reference_query(
    "[splits(\",\")]", "\",,,\"", "[[\"\", \"\", \"\", \"\"]]", 0,
  )
}
