///|
test "missing: pow function" {
  assert_reference_query("pow(2; 3)", "null", "[8]", 0)
}

///|
test "missing: log function" {
  assert_reference_query("log", "10", "[2.302585092994046]", 0)
}

///|
test "missing: exp function" {
  assert_reference_query("exp", "1", "[2.718281828459045]", 0)
}

///|
test "missing: sin, cos, tan" {
  assert_reference_query("sin", "0", "[0]", 0)
  assert_reference_query("cos", "0", "[1]", 0)
  assert_reference_query("tan", "0", "[0]", 0)
}

///|
test "missing: asin, acos, atan" {
  assert_reference_query("asin", "0", "[0]", 0)
  assert_reference_query("acos", "1", "[0]", 0)
  assert_reference_query("atan", "0", "[0]", 0)
}
