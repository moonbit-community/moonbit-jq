///|
test "coverage: numeric builtins mismatches" {
  assert_true((try? coverage_eval("round", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("ceil", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("abs", "\"x\"")) is Err(_))
}

///|
test "coverage: math and range edges" {
  json_inspect(coverage_eval("pow(empty)", "2"), content=[null])
  assert_true((try? coverage_eval("pow(2)", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("log", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("exp", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("sin", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("cos", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("tan", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("asin", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("acos", "\"x\"")) is Err(_))
  assert_true((try? coverage_eval("atan", "\"x\"")) is Err(_))
  json_inspect(coverage_eval("range(empty; 3)", "null"), content=[])
  json_inspect(coverage_eval("range(1; 3; empty)", "null"), content=[])
  assert_true((try? coverage_eval("range(1; \"x\")", "null")) is Err(_))
}
