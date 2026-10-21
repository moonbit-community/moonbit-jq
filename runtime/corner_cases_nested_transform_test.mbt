///|
/// Corner case tests for nested transformations

///|
test "corner: deeply nested object modification" {
  assert_reference_query(
    ".a.b.c.d = 99", "{\"a\":{\"b\":{\"c\":{\"d\":1}}}}", "[{\"a\": {\"b\": {\"c\": {\"d\": 99}}}}]",
    0,
  )
}

///|
test "corner: creating nested structure" {
  assert_reference_query(
    ".a.b.c = 42", "{}", "[{\"a\": {\"b\": {\"c\": 42}}}]", 0,
  )
}

///|
test "corner: array within object modification" {
  assert_reference_query(
    ".items[1].value = 99", "{\"items\":[{\"value\":1},{\"value\":2}]}", "[{\"items\": [{\"value\": 1}, {\"value\": 99}]}]",
    0,
  )
}
