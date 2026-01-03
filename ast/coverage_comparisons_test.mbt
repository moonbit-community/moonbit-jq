///|
test "coverage: null/bool comparisons" {
  @json.inspect(coverage_eval("null < null", "null"), content=[false])
  @json.inspect(coverage_eval("null < false", "null"), content=[true])
  @json.inspect(coverage_eval("false < true", "null"), content=[true])
  @json.inspect(coverage_eval("true > false", "null"), content=[true])
}
