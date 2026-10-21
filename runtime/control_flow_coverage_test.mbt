///|
test "coverage: while yields intermediate values" {
  assert_reference_query("while(. < 4; . + 1)", "1", "[1, 2, 3]", 0)
}

///|
test "coverage: until terminates and returns final value" {
  assert_reference_query("until(. > 3; . + 1)", "1", "[4]", 0)
}

///|
test "coverage: limit takes first N results" {
  assert_reference_query("limit(2; .[])", "[1, 2, 3]", "[1, 2]", 0)
}

///|
test "coverage: reduce aggregates with variable binding" {
  assert_reference_query("reduce .[] as $x (0; . + $x)", "[1, 2, 3]", "[6]", 0)
}

///|
test "coverage: foreach emits running accumulator" {
  assert_reference_query(
    "foreach .[] as $x (0; . + $x)", "[1, 2, 3]", "[1, 3, 6]", 0,
  )
}

///|
test "coverage: foreach supports extract expression" {
  assert_reference_query(
    "foreach .[] as $x (0; . + $x; . * 2)", "[1, 2, 3]", "[2, 6, 12]", 0,
  )
}

///|
test "coverage: scan emits non-overlapping matches" {
  assert_reference_query("scan(\"aa\")", "\"aaaaa\"", "[\"aa\", \"aa\"]", 0)
}

///|
test "coverage: recurse(f; cond) applies f transitively" {
  let input : String =
    #|{
    #|  "a": {
    #|    "a": null
    #|  }
    #|}
  json_inspect(coverage_eval("recurse(.a; . != null)", input), content=[
    { "a": { "a": null } },
    { "a": null },
  ])
}

///|
test "coverage: walk transforms nested numbers" {
  let input : String =
    #|{
    #|  "a": [1, { "b": 2 }],
    #|  "c": "x"
    #|}
  json_inspect(
    coverage_eval("walk(if type == \"number\" then . + 1 else . end)", input),
    content=[{ "a": [2, { "b": 3 }], "c": "x" }],
  )
}
