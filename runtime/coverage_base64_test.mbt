///|
test "coverage: base64 padding and decode edge cases" {
  assert_reference_query("@base64", "\"A\"", "[\"QQ==\"]", 0)
  assert_reference_query("@base64", "\"AB\"", "[\"QUI=\"]", 0)
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
