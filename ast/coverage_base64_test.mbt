///|
test "coverage: base64 padding and decode edge cases" {
  @json.inspect(coverage_eval("@base64", "\"A\""), content=["QQ=="])
  @json.inspect(coverage_eval("@base64", "\"AB\""), content=["QUI="])
  // Exercise '+' and '/' decode table and fail at UTF-8 decoding.
  assert_true((try? coverage_eval("@base64d", "\"++//\"")) is Err(_))
  // Invalid padding sequence.
  assert_true((try? coverage_eval("@base64d", "\"AA=A\"")) is Err(_))
  // Padding in a non-final quantum.
  assert_true((try? coverage_eval("@base64d", "\"AA==AAAA\"")) is Err(_))
  // Invalid character in the 3rd position of a quantum.
  assert_true((try? coverage_eval("@base64d", "\"AA!A\"")) is Err(_))
  // Invalid character in the 4th position of a quantum.
  assert_true((try? coverage_eval("@base64d", "\"AAA!\"")) is Err(_))
  // Invalid character in the 1st/2nd position.
  assert_true((try? coverage_eval("@base64d", "\"!AAA\"")) is Err(_))
  assert_true((try? coverage_eval("@base64d", "\"A!AA\"")) is Err(_))
}
