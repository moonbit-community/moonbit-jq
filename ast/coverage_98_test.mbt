///|
fn cov_eval10(query : String, input : String) -> Array[Json] raise {
  let expr = @parser.parse(query)
  let json_input = @json.parse(input[:])
  @ast.eval(expr, json_input).collect()
}

///|
test "coverage: update operator deep branches" {
  @json.inspect(cov_eval10(".[0] |= . + 1", "{\"a\":1}"), content=[{ "a": 1 }])
  @json.inspect(cov_eval10(".a.b |= . + 1", "{}"), content=[{ "a": null }])
  @json.inspect(cov_eval10(".a.b |= . + 1", "1"), content=[1])
  @json.inspect(
    cov_eval10("(.foo | .bar) |= . + 1", "{\"foo\":{\"bar\":1}}"),
    content=[{ "foo": { "bar": 2 } }],
  )
  @json.inspect(
    cov_eval10("(empty | .bar) |= . + 1", "{\"bar\":1}"),
    content=[{ "bar": 1 }],
  )
  @json.inspect(cov_eval10("length |= empty", "{\"a\":1}"), content=[{ "a": 1 }])
  @json.inspect(cov_eval10("length |= 3", "[1,2]"), content=[3])
  @json.inspect(cov_eval10("empty |= 1", "{\"a\":1}"), content=[{ "a": 1 }])
}

///|
test "coverage: contains, inside, has, in fallbacks" {
  @json.inspect(cov_eval10("contains(\"a\")", "1"), content=[false])
  @json.inspect(cov_eval10("inside(empty)", "\"a\""), content=[false])
  @json.inspect(cov_eval10("inside(\"abc\")", "\"b\""), content=[true])
  @json.inspect(cov_eval10("inside(\"abc\")", "1"), content=[false])
  @json.inspect(cov_eval10("has(\"a\")", "1"), content=[false])
  @json.inspect(cov_eval10("in(empty)", "\"a\""), content=[false])
  @json.inspect(cov_eval10("in({\"a\":1})", "1"), content=[false])
  @json.inspect(cov_eval10("in([1,2])", "\"a\""), content=[false])
  @json.inspect(cov_eval10("in(1)", "\"a\""), content=[false])
}

///|
test "coverage: getpath, while, delpaths edges" {
  @json.inspect(cov_eval10("getpath([1])", "[0]"), content=[null])
  @json.inspect(cov_eval10("while(. < 2; empty)", "1"), content=[1])
  @json.inspect(cov_eval10("delpaths([[1,2]])", "\"x\""), content=["x"])
}

///|
test "coverage: builtin mismatch errors" {
  assert_true((try? cov_eval10("to_entries", "1")) is Err(_))
  assert_true((try? cov_eval10("map_values(.)", "1")) is Err(_))
  assert_true((try? cov_eval10("unique_by(.)", "1")) is Err(_))
  assert_true((try? cov_eval10("transpose", "1")) is Err(_))
  assert_true((try? cov_eval10("range(1; \"x\"; 1)", "null")) is Err(_))
  assert_true((try? cov_eval10("1 % 0", "null")) is Err(_))
}

///|
test "coverage: foreach, min_by, transpose, implode" {
  @json.inspect(
    cov_eval10("foreach .[] as $x (empty; . + $x)", "[1, 2]"),
    content=[],
  )
  @json.inspect(cov_eval10("min_by(.)", "[2, 1]"), content=[1])
  @json.inspect(cov_eval10("transpose", "[[1], 2]"), content=[[[1]]])
  @json.inspect(cov_eval10("implode", "[97, \"x\"]"), content=["a"])
}
