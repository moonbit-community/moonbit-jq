///|
test "coverage: base64 padding and decode edge cases" {
  json_inspect(coverage_eval("@base64", "\"A\""), content=["QQ=="])
  json_inspect(coverage_eval("@base64", "\"AB\""), content=["QUI="])
  // Exercise '+' and '/' decode table and fail at UTF-8 decoding.
  assert_coverage_eval_error("@base64d", "\"++//\"")
  // Invalid padding sequence.
  assert_coverage_eval_error("@base64d", "\"AA=A\"")
  // Padding in a non-final quantum.
  assert_coverage_eval_error("@base64d", "\"AA==AAAA\"")
  // Invalid character in the 3rd position of a quantum.
  assert_coverage_eval_error("@base64d", "\"AA!A\"")
  // Invalid character in the 4th position of a quantum.
  assert_coverage_eval_error("@base64d", "\"AAA!\"")
  // Invalid character in the 1st/2nd position.
  assert_coverage_eval_error("@base64d", "\"!AAA\"")
  assert_coverage_eval_error("@base64d", "\"A!AA\"")
}
