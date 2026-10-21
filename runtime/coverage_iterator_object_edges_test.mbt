///|
test "coverage: iterator empty branch for .[]" {
  assert_reference_query(".[]", "1", "[]", 5)
}

///|
test "coverage: object construction edge cases" {
  assert_reference_query("{(empty): 1, \"a\": 2}", "null", "[]", 0)
  assert_coverage_eval_error("{(1): 2}", "null")
  assert_reference_query("{\"a\": empty}", "null", "[]", 0)
  assert_reference_query("{a}", "1", "[]", 5)
}

///|
test "coverage: object constructor shorthand {a}" {
  assert_reference_query("{a}", "{\"a\": 1}", "[{\"a\": 1}]", 0)
  assert_reference_query("{a}", "{\"b\": 2}", "[{\"a\": null}]", 0)
}
