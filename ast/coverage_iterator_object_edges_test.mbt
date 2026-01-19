///|
test "coverage: iterator empty branch for .[]" {
  json_inspect(coverage_eval(".[]", "1"), content=[])
}

///|
test "coverage: object construction edge cases" {
  json_inspect(coverage_eval("{(empty): 1, \"a\": 2}", "null"), content=[
    { "a": 2 },
  ])
  assert_true((try? coverage_eval("{(1): 2}", "null")) is Err(_))
  json_inspect(coverage_eval("{\"a\": empty}", "null"), content=[{ "a": null }])
  json_inspect(coverage_eval("{a}", "1"), content=[{ "a": null }])
}

///|
test "coverage: object constructor shorthand {a}" {
  json_inspect(coverage_eval("{a}", "{\"a\": 1}"), content=[{ "a": 1 }])
  json_inspect(coverage_eval("{a}", "{\"b\": 2}"), content=[{ "a": null }])
}
