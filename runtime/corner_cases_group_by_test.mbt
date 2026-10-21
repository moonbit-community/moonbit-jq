///|
/// Corner case tests for group_by

///|
test "corner: group_by then sum values" {
  assert_reference_query(
    "group_by(.type) | map({type: .[0].type, sum: map(.val) | add})", "[{\"type\":\"A\",\"val\":1},{\"type\":\"A\",\"val\":2},{\"type\":\"B\",\"val\":3}]",
    "[[{\"type\": \"A\", \"sum\": 3}, {\"type\": \"B\", \"sum\": 3}]]", 0,
  )
}

///|
test "corner: group_by with empty array" {
  assert_reference_query("group_by(.x)", "[]", "[[]]", 0)
}
