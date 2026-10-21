///|
test "coverage: map and min/max edge cases" {
  assert_coverage_eval_error("map(.)", "1")
  assert_reference_query("min", "[]", "[null]", 0)
  assert_reference_query("max", "[]", "[null]", 0)
}

///|
test "coverage: control flow fallbacks" {
  assert_reference_query("if empty then 1 else 2 end", "null", "[]", 0)
  assert_reference_query("try (1 / 0)", "null", "[]", 0)
  assert_reference_query("empty // 2", "null", "[2]", 0)
}

///|
test "coverage: undefined variable" {
  assert_coverage_eval_error("$missing", "null")
}

///|
test "coverage: function argument handling" {
  assert_coverage_eval_error("def f(x; y): $x + $y; f(1)", "null")
  assert_reference_query("def id(x): $x; id(empty)", "null", "[]", 3)
}

///|
test "coverage: reduce and assignment edges" {
  assert_reference_query("reduce .[] as $x (empty; . + $x)", "[1, 2]", "[]", 0)
  assert_reference_query(".a = empty", "{\"a\": 1}", "[]", 0)
}
