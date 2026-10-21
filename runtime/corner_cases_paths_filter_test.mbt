///|
/// Corner case tests for paths filters

///|
test "corner: paths with type filter" {
  assert_reference_query(
    "paths(type == \"number\")", "{\"a\":{\"b\":1,\"c\":\"x\"}}", "[[\"a\", \"b\"]]",
    0,
  )
}

///|
test "corner: paths scalars only" {
  assert_reference_query(
    "paths(scalars)", "{\"a\":1,\"b\":{\"c\":2}}", "[[\"a\"], [\"b\", \"c\"]]", 0,
  )
}
