///|
test "coverage: base64 padding and decode edge cases" {
  @json.inspect(coverage_eval("@base64", "\"A\""), content=["QQ=="])
  @json.inspect(coverage_eval("@base64", "\"AB\""), content=["QUI="])
  // Exercise '+' and '/' decode table and fail at UTF-8 decoding.
  assert_true((try? coverage_eval("@base64d", "\"++//\"")) is Err(_))
  // Invalid padding sequence.
  assert_true((try? coverage_eval("@base64d", "\"AA=A\"")) is Err(_))
}
