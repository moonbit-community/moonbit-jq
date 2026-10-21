///|
test "coverage: foreach extract empty falls back to accumulator" {
  assert_reference_query(
    "foreach .[] as $x (0; . + $x; empty)", "[1, 2]", "[]", 0,
  )
}

///|
test "coverage: scan has misses and type mismatch" {
  assert_reference_query("scan(\"aa\")", "\"abaaa\"", "[\"aa\"]", 0)
  assert_coverage_eval_error("scan(\"a\")", "1")
}

///|
test "coverage: scan skips invalid slice boundaries" {
  let emoji = @encoding/utf8.decode([0xf0, 0x9f, 0x98, 0x80])
  let input = "\"\{emoji}a\""
  json_inspect(coverage_eval("scan(\"a\")", input), content=["a"])
}

///|
test "coverage: compare_json remaining base cases" {
  assert_reference_query("1 > null", "null", "[true]", 0)
  assert_reference_query("false < false", "null", "[false]", 0)
  assert_reference_query("true < true", "null", "[false]", 0)
}

///|
test "coverage: and/or truthiness behavior" {
  assert_reference_query("false and 1", "null", "[false]", 0)
  assert_reference_query("null and 1", "null", "[false]", 0)
  assert_reference_query("1 and 2", "null", "[true]", 0)
  assert_reference_query("false or 2", "null", "[true]", 0)
  assert_reference_query("null or 2", "null", "[true]", 0)
  assert_reference_query("1 or 2", "null", "[true]", 0)
}

///|
test "coverage: delpaths and setpath edge cases" {
  assert_reference_query("delpaths([[]])", "[1]", "[null]", 0)
  json_inspect(coverage_eval("delpaths([[\"a\"]])", "[1]"), content=[[1]])
  assert_reference_query("delpaths([[10]])", "[1]", "[[1]]", 0)
  assert_reference_query("delpaths([[1, 0]])", "[1]", "[[1]]", 0)
  json_inspect(coverage_eval("setpath([\"a\"]; 1)", "[0]"), content=[[0]])
}

///|
test "coverage: modulo rejects non-numbers" {
  assert_coverage_eval_error("null % 2", "null")
}
