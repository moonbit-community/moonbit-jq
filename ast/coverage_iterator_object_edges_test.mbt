///|
test "coverage: iterator empty branch for .[]" {
  @json.inspect(coverage_eval(".[]", "1"), content=[])
}

///|
test "coverage: object construction edge cases" {
  @json.inspect(coverage_eval("{(empty): 1, \"a\": 2}", "null"), content=[
    { "a": 2 },
  ])
  assert_true((try? coverage_eval("{(1): 2}", "null")) is Err(_))
  @json.inspect(coverage_eval("{\"a\": empty}", "null"), content=[{ "a": null }])
  @json.inspect(coverage_eval("{a}", "1"), content=[{ "a": null }])
}

///|
test "coverage: object constructor shorthand {a}" {
  @json.inspect(coverage_eval("{a}", "{\"a\": 1}"), content=[{ "a": 1 }])
  @json.inspect(coverage_eval("{a}", "{\"b\": 2}"), content=[{ "a": null }])
}
