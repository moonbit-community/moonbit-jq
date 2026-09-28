// Regression tests for bugs found by the property tests in moonjq_qc_test.mbt.

///|
fn regression_run(query : String, input : String) -> Array[Json] raise {
  @moonjq.run(query, input)
}

///|
test "regression: values of different types never compare equal" {
  // Found by "qc: comparison operators follow jq's total order":
  // `{} == 0` was true because non-adjacent type pairs fell through to 0.
  json_inspect(
    regression_run("[{} == 0, [] == 0, [] == \"\", {} < 0]", "null"),
    content=[[false, false, false, false]],
  )
}

///|
test "regression: objects are ordered by sorted keys then values" {
  json_inspect(regression_run("{\"a\":1} == {\"b\":2}", "null"), content=[false])
  json_inspect(regression_run("{\"a\":1} < {\"b\":0}", "null"), content=[true])
  json_inspect(regression_run("{\"a\":2} > {\"a\":1}", "null"), content=[true])
  // `unique` used to collapse every object into the first one.
  json_inspect(
    regression_run("unique", "[{\"b\":1},{\"a\":2},{\"a\":1},{\"a\":1}]"),
    content=[[{ "a": 1 }, { "a": 2 }, { "b": 1 }]],
  )
}

///|
test "regression: strings are ordered by code point, not length first" {
  // Found by "qc: sort is sorted, a permutation, and idempotent".
  json_inspect(regression_run("sort", "[\"b\",\"aa\"]"), content=[["aa", "b"]])
  json_inspect(regression_run("\"aa\" < \"b\"", "null"), content=[true])
  // U+FFFF sorts before U+1F600 by code point (UTF-16 units disagree).
  json_inspect(regression_run("sort", "[\"\\ud83d\\ude00\",\"\\uffff\"]"), content=[
    ["\u{FFFF}", "😀"],
  ])
}
