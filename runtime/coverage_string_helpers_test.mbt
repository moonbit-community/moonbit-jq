///|
test "coverage: more string search helpers" {
  assert_reference_query("index(\"foo\")", "\"foobar\"", "[0]", 0)
  assert_reference_query("indices(\"o\")", "\"foobar\"", "[[1, 2]]", 0)
}

///|
test "string index operations" {
  // index: find first occurrence
  assert_reference_query("index(\"bc\")", "\"abcabc\"", "[1]", 0)
  assert_reference_query("index(\"xyz\")", "\"abcabc\"", "[null]", 0)
  assert_reference_query("index(\"abc\")", "\"abcabc\"", "[0]", 0)
  assert_reference_query("index(\"c\")", "\"abcabc\"", "[2]", 0)
  assert_reference_query("index(\"world\")", "\"hello world\"", "[6]", 0)
  // indices: find all occurrences
  assert_reference_query("indices(\"bc\")", "\"abcabc\"", "[[1, 4]]", 0)
  assert_reference_query("indices(\"a\")", "\"abcabc\"", "[[0, 3]]", 0)
  assert_reference_query("indices(\"xyz\")", "\"abcabc\"", "[[]]", 0)
  assert_reference_query("indices(\"abc\")", "\"abcabc\"", "[[0, 3]]", 0)
  assert_reference_query("indices(\"abc\")", "\"abcabcabc\"", "[[0, 3, 6]]", 0)
  // Overlapping matches (jq behavior: finds overlapping matches)
  assert_reference_query("indices(\"aa\")", "\"aaaa\"", "[[0, 1, 2]]", 0)
  // Edge cases
  assert_reference_query("indices(\"\")", "\"abc\"", "[[]]", 0)
  assert_reference_query("index(\"\")", "\"abc\"", "[null]", 0)
}

///|
test "coverage: @html escapes ampersand and quotes" {
  json_inspect(coverage_eval("@html", "\"&\\\"'\""), content=[
    "&amp;&quot;&#39;",
  ])
}

///|
test "coverage: text builders preserve unicode output" {
  assert_reference_query(
    "@html", "\"<&世界&>\"", "[\"&lt;&amp;世界&amp;&gt;\"]", 0,
  )
  assert_reference_query(
    "\"Hello \\(.name)\"", "{\"name\":\"世界\"}", "[\"Hello 世界\"]", 0,
  )
}
