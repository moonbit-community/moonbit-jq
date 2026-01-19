///|
test "coverage: math functions" {
  json_inspect(coverage_eval("pow(3)", "2"), content=[8])
  json_inspect(coverage_eval("log", "1"), content=[0])
  json_inspect(coverage_eval("exp", "0"), content=[1])
  json_inspect(coverage_eval("sin", "0"), content=[0])
  json_inspect(coverage_eval("cos", "0"), content=[1])
  json_inspect(coverage_eval("tan", "0"), content=[0])
  json_inspect(coverage_eval("asin", "0"), content=[0])
  json_inspect(coverage_eval("acos", "1"), content=[0])
  json_inspect(coverage_eval("atan", "0"), content=[0])
  assert_true((try? coverage_eval("sin", "\"x\"")) is Err(_))
}
