///|
/// Corner case tests for splits

///|
test "corner: splits with single delimiter" {
  inspect(
    test_query("[splits(\",\")]", "\"a,b,c,d\""),
    content="Array([String(\"a\"), String(\"b\"), String(\"c\"), String(\"d\")])",
  )
}

///|
test "corner: splits with empty result" {
  inspect(
    test_query("[splits(\",\")]", "\",,,\""),
    content="Array([String(\"\"), String(\"\"), String(\"\"), String(\"\")])",
  )
}
