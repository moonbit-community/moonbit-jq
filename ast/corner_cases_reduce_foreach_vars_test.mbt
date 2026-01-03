///|
/// Corner case tests for variables, reduce, and foreach

// ============================================================================
// Variable Binding Edge Cases
// ============================================================================

///|
test "corner: multiple variable bindings" {
  inspect(test_query(". as $x | 10 as $y | $x + $y", "5"), content="Number(15)")
}

///|
test "corner: variable shadowing" {
  inspect(test_query(". as $x | (20 as $x | $x)", "10"), content="Number(20)")
}

///|
test "corner: variable in nested context" {
  inspect(
    test_query(". as $x | [1,2,3] | map(. + $x)", "10"),
    content="Array([Number(11), Number(12), Number(13)])",
  )
}

// ============================================================================
// Reduce Edge Cases
// ============================================================================

///|
test "corner: reduce with array elements" {
  inspect(
    test_query("reduce .[] as $item (0; . + $item)", "[1,2,3,4,5]"),
    content="Number(15)",
  )
}

///|
test "corner: reduce with empty array" {
  inspect(
    test_query("reduce .[] as $item (0; . + $item)", "[]"),
    content="Number(0)",
  )
}

///|
test "corner: reduce building object" {
  inspect(
    test_query(
      "reduce .[] as $item ({}; . + {($item.key): $item.value})", "[{\"key\":\"a\",\"value\":1},{\"key\":\"b\",\"value\":2}]",
    ),
    content="Object({\"a\": Number(1), \"b\": Number(2)})",
  )
}

///|
test "corner: reduce with multiplication" {
  inspect(
    test_query("reduce .[] as $x (1; . * $x)", "[2,3,4]"),
    content="Number(24)",
  )
}

// ============================================================================
// Foreach
// ============================================================================

///|
test "corner: foreach accumulating values" {
  inspect(
    test_query("foreach .[] as $item (0; . + $item)", "[1,2,3]"),
    content="Number(1), Number(3), Number(6)",
  )
}

///|
test "corner: foreach with transformation" {
  inspect(
    test_query("foreach .[] as $item (0; . + $item; . * 2)", "[1,2,3]"),
    content="Number(2), Number(6), Number(12)",
  )
}

///|
test "corner: foreach with empty array" {
  inspect(test_query("foreach .[] as $item (0; . + $item)", "[]"), content="")
}
