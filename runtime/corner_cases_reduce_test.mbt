///|
/// Corner case tests for reduce

///|
test "corner: reduce with array elements" {
  assert_reference_query(
    "reduce .[] as $item (0; . + $item)", "[1,2,3,4,5]", "[15]", 0,
  )
}

///|
test "corner: reduce with empty array" {
  assert_reference_query("reduce .[] as $item (0; . + $item)", "[]", "[0]", 0)
}

///|
test "corner: reduce building object" {
  assert_reference_query(
    "reduce .[] as $item ({}; . + {($item.key): $item.value})", "[{\"key\":\"a\",\"value\":1},{\"key\":\"b\",\"value\":2}]",
    "[{\"a\": 1, \"b\": 2}]", 0,
  )
}

///|
test "corner: reduce with multiplication" {
  assert_reference_query("reduce .[] as $x (1; . * $x)", "[2,3,4]", "[24]", 0)
}
