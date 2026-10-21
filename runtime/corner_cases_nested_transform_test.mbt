///|
/// Corner case tests for nested transformations

///|
test "corner: deeply nested object modification" {
  debug_inspect(
    test_query(".a.b.c.d = 99", "{\"a\":{\"b\":{\"c\":{\"d\":1}}}}"),
    content=(
      #|"Object({ \"a\": Object({ \"b\": Object({ \"c\": Object({ \"d\": Number(99) }) }) }) })"
    ),
  )
}

///|
test "corner: creating nested structure" {
  debug_inspect(
    test_query(".a.b.c = 42", "{}"),
    content=(
      #|"Object({ \"a\": Object({ \"b\": Object({ \"c\": Number(42) }) }) })"
    ),
  )
}

///|
test "corner: array within object modification" {
  debug_inspect(
    test_query(
      ".items[1].value = 99", "{\"items\":[{\"value\":1},{\"value\":2}]}",
    ),
    content=(
      #|"Object({ \"items\": Array([Object({ \"value\": Number(1) }), Object({ \"value\": Number(99) })]) })"
    ),
  )
}
