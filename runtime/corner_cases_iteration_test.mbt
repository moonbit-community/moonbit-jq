///|
/// Corner case tests for range and iteration

///|
test "corner: range with single argument" {
  assert_reference_query("[range(5)]", "null", "[[0, 1, 2, 3, 4]]", 0)
}

///|
test "corner: range with start and end" {
  assert_reference_query("[range(2;5)]", "null", "[[2, 3, 4]]", 0)
}

///|
test "corner: range with step" {
  assert_reference_query("[range(0;10;2)]", "null", "[[0, 2, 4, 6, 8]]", 0)
}

///|
test "corner: range with negative step" {
  assert_reference_query("[range(10;0;-2)]", "null", "[[10, 8, 6, 4, 2]]", 0)
}

///|
test "corner: range with zero count" {
  assert_reference_query("[range(0)]", "null", "[[]]", 0)
}

///|
test "corner: first from multiple values" {
  assert_reference_query("first(1,2,3,4,5)", "null", "[1]", 0)
}

///|
test "corner: last from multiple values" {
  assert_reference_query("last(1,2,3,4,5)", "null", "[5]", 0)
}

///|
test "corner: first from array elements" {
  assert_reference_query("first(.[])", "[10,20,30]", "[10]", 0)
}

///|
test "corner: last from array elements" {
  assert_reference_query("last(.[])", "[10,20,30]", "[30]", 0)
}

///|
test "corner: first with empty" {
  assert_reference_query("first(empty)", "null", "[]", 0)
}

///|
test "corner: repeat generates infinite stream (limited)" {
  assert_reference_query(
    "limit(3; repeat(\"x\"))", "null", "[\"x\", \"x\", \"x\"]", 0,
  )
}

///|
test "corner: repeat with expression" {
  assert_reference_query("limit(4; . | repeat(. * 2))", "1", "[2, 2, 2, 2]", 0)
}

///|
test "corner: until increments until condition" {
  assert_reference_query("until(. > 5; . + 1)", "1", "[6]", 0)
}

///|
test "corner: until with already satisfied condition" {
  assert_reference_query("until(. > 5; . + 1)", "10", "[10]", 0)
}

///|
test "corner: until with decrement" {
  assert_reference_query("until(. < 0; . - 1)", "5", "[-1]", 0)
}
