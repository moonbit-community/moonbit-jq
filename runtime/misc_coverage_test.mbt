///|
test "coverage: .[] iterates object values" {
  // Object iteration preserves insertion order.
  assert_reference_query(".[]", "{\"a\": 1, \"b\": 2}", "[1, 2]", 0)
}

///|
test "coverage: index on non-array yields nulls" {
  assert_reference_query(".[0, 1]", "{\"a\": 1}", "[]", 5)
}

///|
test "coverage: slice on non-array yields null" {
  assert_reference_query(".[1:2]", "1", "[]", 5)
}

///|
test "coverage: optional suppresses evaluation errors" {
  assert_reference_query("(1 / 0)?", "null", "[]", 0)
}

///|
test "coverage: in(array) checks index bounds" {
  assert_reference_query("0 | in([10, 20])", "null", "[true]", 0)
  assert_reference_query("1 | in([10, 20])", "null", "[true]", 0)
  assert_reference_query("2 | in([10, 20])", "null", "[false]", 0)
  assert_reference_query("-1 | in([10, 20])", "null", "[false]", 0)
}

///|
test "coverage: object-object comparison uses object ordering" {
  assert_reference_query("{\"a\":1} < {\"b\":2}", "null", "[true]", 0)
}

///|
test "coverage: comparisons across JSON types" {
  assert_reference_query("false < 0", "null", "[true]", 0)
  assert_reference_query("0 > false", "null", "[true]", 0)
  assert_reference_query("0 < \"x\"", "null", "[true]", 0)
  assert_reference_query("\"x\" > 0", "null", "[true]", 0)
  assert_reference_query("\"x\" < [0]", "null", "[true]", 0)
  assert_reference_query("[0] > \"x\"", "null", "[true]", 0)
  assert_reference_query("[0] < {\"a\":1}", "null", "[true]", 0)
  assert_reference_query("{\"a\":1} > [0]", "null", "[true]", 0)
}

///|
test "coverage: foreach copies env bindings and functions" {
  assert_reference_query(
    "def f: $x; 10 as $x | foreach .[] as $y (0; . + $y + f)", "[1, 2]", "[]", 3,
  )
}

///|
test "coverage: function call validates argument count" {
  assert_coverage_eval_error("def add(a; b): a + b; add(1)", "null")
}

///|
test "coverage: undefined function errors" {
  assert_coverage_eval_error("no_such_fn", "null")
}
