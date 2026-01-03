///|
/// Corner case tests for matrix and ASCII operations

// ============================================================================
// Splits with Regex-like Patterns
// ============================================================================

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

// ============================================================================
// Combinations
// ============================================================================

///|
test "corner: combinations of two arrays" {
  inspect(
    test_query("[[1,2],[3,4]] | combinations", "null"),
    content="Array([Number(1), Number(3)]), Array([Number(1), Number(4)]), Array([Number(2), Number(3)]), Array([Number(2), Number(4)])",
  )
}

///|
test "corner: combinations with empty array" {
  inspect(test_query("[[], [1,2]] | combinations", "null"), content="")
}

///|
test "corner: combinations of three arrays" {
  inspect(
    test_query("[[1,2],[3],[4,5]] | combinations", "null"),
    content="Array([Number(1), Number(3), Number(4)]), Array([Number(1), Number(3), Number(5)]), Array([Number(2), Number(3), Number(4)]), Array([Number(2), Number(3), Number(5)])",
  )
}

// ============================================================================
// Transpose
// ============================================================================

///|
test "corner: transpose matrix" {
  inspect(
    test_query("transpose", "[[1,2,3],[4,5,6]]"),
    content="Array([Array([Number(1), Number(4)]), Array([Number(2), Number(5)]), Array([Number(3), Number(6)])])",
  )
}

///|
test "corner: transpose with uneven rows" {
  inspect(
    test_query("transpose", "[[1,2,3],[4,5],[6]]"),
    content="Array([Array([Number(1), Number(4), Number(6)]), Array([Number(2), Number(5)]), Array([Number(3)])])",
  )
}

///|
test "corner: transpose empty matrix" {
  inspect(test_query("transpose", "[]"), content="Array([])")
}

// ============================================================================
// ASCII and Character Operations
// ============================================================================

///|
test "corner: ascii_downcase preserves non-ASCII" {
  inspect(
    test_query("ascii_downcase", "\"CAFÉ\""),
    content="String(\"cafÉ\")",
  )
}

///|
test "corner: ascii_upcase preserves non-ASCII" {
  inspect(
    test_query("ascii_upcase", "\"café\""),
    content=(
      #|String("CAFé")
    ),
  )
}
