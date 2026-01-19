///|
test "coverage: null/bool comparisons" {
  json_inspect(coverage_eval("null < null", "null"), content=[false])
  json_inspect(coverage_eval("null < false", "null"), content=[true])
  json_inspect(coverage_eval("false < true", "null"), content=[true])
  json_inspect(coverage_eval("true > false", "null"), content=[true])
}
