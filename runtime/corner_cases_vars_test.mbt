///|
/// Corner case tests for variable binding

///|
test "corner: multiple variable bindings" {
  assert_reference_query(". as $x | 10 as $y | $x + $y", "5", "[15]", 0)
}

///|
test "corner: variable shadowing" {
  assert_reference_query(". as $x | (20 as $x | $x)", "10", "[20]", 0)
}

///|
test "corner: variable in nested context" {
  assert_reference_query(
    ". as $x | [1,2,3] | map(. + $x)", "10", "[[11, 12, 13]]", 0,
  )
}
