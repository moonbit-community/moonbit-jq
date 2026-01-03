///|
/// Corner case tests for conversions and iteration

// ============================================================================
// String/Array Conversion
// ============================================================================

///|
test "corner: explode converts string to codepoints" {
  inspect(
    test_query("explode", "\"Hello\""),
    content="Array([Number(72), Number(101), Number(108), Number(108), Number(111)])",
  )
}

///|
test "corner: implode converts codepoints to string" {
  inspect(
    test_query("implode", "[72,101,108,108,111]"),
    content="String(\"Hello\")",
  )
}

///|
test "corner: explode with unicode" {
  inspect(
    test_query("explode", "\"世界\""),
    content="Array([Number(19990), Number(30028)])",
  )
}

///|
test "corner: implode with unicode codepoints" {
  inspect(test_query("implode", "[19990,30028]"), content="String(\"世界\")")
}

// ============================================================================
// Range and Iteration
// ============================================================================

///|
test "corner: range with single argument" {
  inspect(
    test_query("[range(5)]", "null"),
    content="Array([Number(0), Number(1), Number(2), Number(3), Number(4)])",
  )
}

///|
test "corner: range with start and end" {
  inspect(
    test_query("[range(2;5)]", "null"),
    content="Array([Number(2), Number(3), Number(4)])",
  )
}

///|
test "corner: range with step" {
  inspect(
    test_query("[range(0;10;2)]", "null"),
    content="Array([Number(0), Number(2), Number(4), Number(6), Number(8)])",
  )
}

///|
test "corner: range with negative step" {
  inspect(
    test_query("[range(10;0;-2)]", "null"),
    content="Array([Number(10), Number(8), Number(6), Number(4), Number(2)])",
  )
}

///|
test "corner: range with zero count" {
  inspect(test_query("[range(0)]", "null"), content="Array([])")
}

// ============================================================================
// First and Last
// ============================================================================

///|
test "corner: first from multiple values" {
  inspect(test_query("first(1,2,3,4,5)", "null"), content="Number(1)")
}

///|
test "corner: last from multiple values" {
  inspect(test_query("last(1,2,3,4,5)", "null"), content="Number(5)")
}

///|
test "corner: first from array elements" {
  inspect(test_query("first(.[])", "[10,20,30]"), content="Number(10)")
}

///|
test "corner: last from array elements" {
  inspect(test_query("last(.[])", "[10,20,30]"), content="Number(30)")
}

///|
test "corner: first with empty" {
  inspect(test_query("first(empty)", "null"), content="")
}

// ============================================================================
// Repeat
// ============================================================================

///|
test "corner: repeat generates infinite stream (limited)" {
  inspect(
    test_query("limit(3; repeat(\"x\"))", "null"),
    content="String(\"x\"), String(\"x\"), String(\"x\")",
  )
}

///|
test "corner: repeat with expression" {
  inspect(
    test_query("limit(4; . | repeat(. * 2))", "1"),
    content="Number(2), Number(2), Number(2), Number(2)",
  )
}

// ============================================================================
// Until
// ============================================================================

///|
test "corner: until increments until condition" {
  inspect(test_query("until(. > 5; . + 1)", "1"), content="Number(6)")
}

///|
test "corner: until with already satisfied condition" {
  inspect(test_query("until(. > 5; . + 1)", "10"), content="Number(10)")
}

///|
test "corner: until with decrement" {
  inspect(test_query("until(. < 0; . - 1)", "5"), content="Number(-1)")
}
