///|
test "coverage: flatten default depth flattens all" {
  assert_reference_query("flatten", "[1, [2, [3]]]", "[[1, 2, 3]]", 0)
}

///|
test "coverage: flatten(n) flattens one level" {
  assert_reference_query("flatten(1)", "[1, [2, [3]]]", "[[1, 2, [3]]]", 0)
}

///|
test "coverage: flatten rejects non-array" {
  assert_coverage_eval_error("flatten", "1")
}

///|
test "coverage: unique sorts and removes duplicates" {
  assert_reference_query("unique", "[3, 1, 3, 2]", "[[1, 2, 3]]", 0)
}

///|
test "coverage: to_entries supports arrays" {
  assert_reference_query(
    "to_entries", "[\"a\", \"b\"]", "[[{\"key\": 0, \"value\": \"a\"}, {\"key\": 1, \"value\": \"b\"}]]",
    0,
  )
}

///|
test "coverage: from_entries supports numeric keys and name fallback" {
  json_inspect(coverage_eval("from_entries", "[{\"key\":0,\"value\":\"a\"}]"), content=[
    { "0": "a" },
  ])
  assert_reference_query(
    "from_entries", "[{\"name\":\"a\",\"value\":1}]", "[{\"a\": 1}]", 0,
  )
}

///|
test "coverage: with_entries round-trips object" {
  assert_reference_query(
    "with_entries(.)", "{\"a\": 1, \"b\": 2}", "[{\"a\": 1, \"b\": 2}]", 0,
  )
}
