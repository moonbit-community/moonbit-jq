///|
test "coverage: update operator branches" {
  assert_reference_query(". |= empty", "1", "[null]", 0)
  assert_reference_query(". |= 2", "1", "[2]", 0)
  assert_reference_query(".a |= empty", "{\"a\": 1}", "[{}]", 0)
  assert_reference_query(".a |= . + 1", "1", "[]", 5)
  assert_reference_query(".[0] |= empty", "[1]", "[[]]", 0)
  assert_reference_query(
    ".[10] |= . + 1", "[1]", "[[1, null, null, null, null, null, null, null, null, null, 1]]",
    0,
  )
  assert_reference_query(".[] |= .", "[1, 2]", "[[1, 2]]", 0)
  assert_reference_query(
    ".a[10] |= . + 1", "{\"a\": [1]}", "[{\"a\": [1, null, null, null, null, null, null, null, null, null, 1]}]",
    0,
  )
  assert_reference_query(
    ".foo.bar |= . + 1", "{\"foo\": {\"bar\": 1}}", "[{\"foo\": {\"bar\": 2}}]",
    0,
  )
  assert_reference_query(
    ".foo[0] |= . + 1", "{\"foo\": [1]}", "[{\"foo\": [2]}]", 0,
  )
}

///|
test "coverage: walk empty results and recurse safety" {
  assert_reference_query("walk(empty)", "[1, 2]", "[]", 0)
  assert_reference_query("walk(empty)", "{\"a\": 1}", "[]", 0)
  assert_reference_query("walk(empty)", "1", "[]", 0)
  let nums : Array[String] = []
  for i in 0..<101 {
    nums.push(i.to_string())
  }
  let sep = ","
  let input = "[\{nums.join(sep)}]"
  let results = coverage_eval("recurse(.[]?; . != null)", input)
  debug_inspect(results.length(), content="102")
}
