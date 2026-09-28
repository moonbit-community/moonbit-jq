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

///|
test "regression: paths(f) yields numeric array indices" {
  // Found by "qc: paths(f) is paths filtered by f on the value at the
  // path": array indices came out as strings ("0"), unlike `paths`.
  json_inspect(
    regression_run("[paths(type == \"number\")]", "{\"a\":[1,{\"c\":2}]}"),
    content=[[["a", 0], ["a", 1, "c"]]],
  )
  // The root is never a candidate, so an error from f on the root must not
  // stop the enumeration.
  json_inspect(
    regression_run("[paths(ascii_downcase == \"x\")]", "{\"k\":\"X\"}"),
    content=[[["k"]]],
  )
}

///|
test "regression: setpath creates missing structure" {
  // Found by "qc: setpath on null builds the path" (path [1] on null) and
  // by probing: missing intermediate keys were replaced by null, dropping
  // the value, and out-of-range indices were ignored.
  json_inspect(regression_run("setpath([1]; {})", "null"), content=[[null, {}]])
  json_inspect(regression_run("setpath([\"b\",\"c\"]; 5)", "{\"a\":[1]}"), content=[
    { "a": [1], "b": { "c": 5 } },
  ])
  json_inspect(regression_run("setpath([\"a\",2]; 5)", "{\"a\":[1]}"), content=[
    { "a": [1, null, 5] },
  ])
  json_inspect(
    regression_run(
      "setpath([\"a\",0,\"b\"]; 1) | getpath([\"a\",0,\"b\"])", "null",
    ),
    content=[1],
  )
}

///|
test "regression: query string literals may contain astral characters" {
  // Found while checking the paths(f) property with keys like "😀": the
  // lexer advanced one UTF-16 unit per character, landed inside the
  // surrogate pair and reported UnterminatedString.
  json_inspect(
    regression_run("\"😀\", (. == \"a😀b\"), {\"😀\": 1}", "\"a😀b\""),
    content=["😀", true, { "😀": 1 }],
  )
}

///|
test "regression: query string literals accept \\f and \\uXXXX escapes" {
  // Found by "qc: paths(f) is paths filtered by f on the value at the path"
  // with the key "\f": JSON escapes \f and \uXXXX were rejected with
  // InvalidEscape, so a stringified path could not be used in a query.
  json_inspect(
    regression_run(
      "\"\\f\", \"\\u00e9\\u0041\", \"\\ud83d\\ude00\", \"\\ud800x\"", "null",
    ),
    content=["\u{0C}", "éA", "😀", "\u{FFFD}x"],
  )
  json_inspect(regression_run("getpath([\"\\f\"])", "{\"\\f\":0}"), content=[0])
}

///|
test "regression: tostring is defined" {
  // Found by "qc: tostring is identity on strings and tojson otherwise":
  // `tostring` raised "Undefined function: tostring".
  json_inspect(
    regression_run(
      "[.[] | tostring]", "[\"a\", 1, null, [true], {\"k\":\"v\"}]",
    ),
    content=[["a", "1", "null", "[true]", "{\"k\":\"v\"}"]],
  )
}

///|
test "regression: path(f) returns the paths f refers to" {
  // Found by "qc: paths, path(..) and .. agree with a reference traversal":
  // `path` was not parsed ("Undefined function: path") and the AST node
  // always evaluated to [].
  json_inspect(regression_run("[path(..)]", "{\"a\":[1]}"), content=[
    [[], ["a"], ["a", 0]],
  ])
  json_inspect(
    regression_run(
      "[path(.a[0], .[]?, (.. | select(type == \"number\")), getpath([\"x\",\"y\"]), first(.a[]))]",
      "{\"a\":[1]}",
    ),
    content=[[["a", 0], ["a"], ["a", 0], ["x", "y"], ["a", 0]]],
  )
  try regression_run("path(1)", "null") catch {
    _ => ()
  } noraise {
    _ => fail("path(1) is not a path expression")
  }
}

///|
test "regression: p = v sets the paths of p instead of returning v" {
  // Found while writing the path properties: `.a = 1` returned 1.
  json_inspect(regression_run(".a = 1", "{\"b\":2}"), content=[
    { "b": 2, "a": 1 },
  ])
  json_inspect(regression_run(".a = .b", "{\"b\":5}"), content=[
    { "b": 5, "a": 5 },
  ])
  json_inspect(regression_run("(.a, .b) = (1, 2)", "{}"), content=[
    { "a": 1, "b": 1 },
    { "a": 2, "b": 2 },
  ])
  json_inspect(regression_run(".a = empty", "{\"a\":1}"), content=[])
}

///|
test "regression: p |= f updates every path of p in place" {
  // `.a.b.c |= 2` returned only the innermost object, `.[] |= f` left the
  // array unchanged and `(.a, .b) |= 3` returned 3.
  json_inspect(regression_run(".a.b.c |= 2", "{\"a\":{\"b\":{\"c\":1}}}"), content=[
    { "a": { "b": { "c": 2 } } },
  ])
  json_inspect(regression_run(".[] |= . + 1", "[1,2]"), content=[[2, 3]])
  json_inspect(regression_run("(.a, .b) |= 3", "{}"), content=[
    { "a": 3, "b": 3 },
  ])
  json_inspect(regression_run(".a.b += 1", "{}"), content=[{ "a": { "b": 1 } }])
}

///|
test "regression: // chains right-associatively" {
  // `.a // .b // .c // "default"` parsed only the first `//` and silently
  // dropped the rest of the query, returning null.
  json_inspect(regression_run(".a // .b // .c // \"default\"", "{\"c\":5}"), content=[
    5,
  ])
  json_inspect(regression_run(".a // .b // \"default\"", "{}"), content=[
    "default",
  ])
  json_inspect(regression_run("(.a = 1) // 2, (.a = 1 // 2)", "{}"), content=[
    { "a": 1 },
    { "a": 1 },
  ])
}

///|
test "regression: trailing tokens are a parse error" {
  // `. 1`, `.a )` and `."a"` used to parse as their first complete
  // expression and ignore the rest (`."a"` returned the whole input).
  for query in [". 1", ".a )", "def f: .; f g"] {
    try @moonjq.parse(query) catch {
      _ => ()
    } noraise {
      _ => fail("expected a parse error for \{query}")
    }
  }
}

///|
test "regression: .\"key\" and .[\"key\"] access object keys" {
  // Needed to turn generated paths back into filters in "qc: filters built
  // from paths agree with getpath and path"; `.["a"]` was a syntax error
  // and `."a"` returned the whole input.
  json_inspect(
    regression_run(
      ".\"a b\", .[\"a b\"], .x.\"k\", .x[\"k\"], .[\"x\"][\"k\"]", "{\"a b\":1,\"x\":{\"k\":2}}",
    ),
    content=[1, 1, 2, 2, 2],
  )
  json_inspect(regression_run("path(.[\"a\"][0]), (.[\"a\"] = 3)", "{}"), content=[
    ["a", 0],
    { "a": 3 },
  ])
}

///|
test "regression: getpath accepts negative array indices" {
  // `path(.[-1])` is [-1], but getpath([-1]) returned null, so
  // `.[-1] |= . + 1` computed null + 1.
  json_inspect(
    regression_run("getpath([-1]), getpath([-3]), (.[-1] |= . + 1)", "[1,2]"),
    content=[2, null, [1, 3]],
  )
}

///|
test "regression: select and if act on every condition output" {
  // Review of PR #30 (checked against jq 1.7.1): only the first condition
  // output was used, and an empty condition ran the else branch.
  // jq 1.7.1: `{"a":1} | [path(select(false,true))]` => [[]]
  json_inspect(regression_run("[path(select(false, true))]", "{\"a\":1}"), content=[
    [[]],
  ])
  // jq 1.7.1: `{} | (if empty then .a else .b end) = 2` => {}
  json_inspect(regression_run("(if empty then .a else .b end) = 2", "{}"), content=[
    {},
  ])
  // jq 1.7.1: [select(true,true)] => [1,1]; [if (true,false) then 1 else 2
  // end] => [1,2]; [if empty then 1 else 2 end] => []
  json_inspect(
    regression_run(
      "[select(true, true)], [if (true, false) then 1 else 2 end], [if empty then 1 else 2 end]",
      "1",
    ),
    content=[[1, 1], [1, 2], []],
  )
}
