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

///|
test "regression: tojson produces JSON text that fromjson reads back" {
  // Found by "qc: tojson | fromjson round-trips": tojson returned the Debug
  // representation (`Object({ "a": Number(1) })`), which fromjson rejected.
  json_inspect(regression_run("tojson", "{\"a\":[1,\"x\\n\",null,true]}"), content=[
    "{\"a\":[1,\"x\\n\",null,true]}",
  ])
  json_inspect(regression_run("tojson | fromjson", "{\"a\":[1,null]}"), content=[
    { "a": [1, null] },
  ])
  // The same Debug text leaked into interpolation, @json, @text and join.
  json_inspect(
    regression_run(
      "\"\\(.a) \\(.b) \\(.c)\", @json, @text, ([.a, .c, \"s\"] | join(\"-\"))",
      "{\"a\":1,\"b\":[true],\"c\":null}",
    ),
    content=[
      "1 [true] null", "{\"a\":1,\"b\":[true],\"c\":null}", "{\"a\":1,\"b\":[true],\"c\":null}",
      "1--s",
    ],
  )
}

///|
test "regression: add follows reduce .[] as $x (null; . + $x)" {
  // Found by "qc: add concatenates strings and arrays": add summed only the
  // numbers, so string/array inputs gave 0 and `[] | add` gave 0.
  json_inspect(regression_run("add", "[\"a\",\"b\"]"), content=["ab"])
  json_inspect(regression_run("add", "[[1],[2]]"), content=[[1, 2]])
  json_inspect(regression_run("add", "[{\"a\":1},{\"b\":2}]"), content=[
    { "a": 1, "b": 2 },
  ])
  json_inspect(regression_run("add", "[]"), content=[null])
  // null is the identity for `+`.
  json_inspect(regression_run("[null + 1, 1 + null, null + null]", "null"), content=[
    [1, 1, null],
  ])
}

///|
test "regression: length counts code points and is abs for numbers" {
  // Found by "qc: length agrees with the value": `0 | length` raised and an
  // astral character counted as 2 (UTF-16 code units).
  json_inspect(
    regression_run("[.[] | length]", "[0, -5, 2.5, \"\\ud83d\\ude00\", \"é\"]"),
    content=[[0, 5, 2.5, 1, 1]],
  )
}

///|
test "regression: map works on objects like [.[] | f]" {
  // Found by "qc: map(f) == [.[] | f]" with input {}: map raised a type
  // error for objects.
  json_inspect(regression_run("map(. + 1)", "{\"b\":1,\"a\":2}"), content=[
    [2, 3],
  ])
  json_inspect(regression_run("map(.)", "{}"), content=[[]])
}
