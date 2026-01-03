///|
test "missing: pow function" {
  inspect(test_feature("pow(2; 3)", "null"), content="Number(8)")
}

///|
test "missing: log function" {
  inspect(test_feature("log", "10"), content="Number(2.302585092994046)")
}

///|
test "missing: exp function" {
  inspect(test_feature("exp", "1"), content="Number(2.718281828459045)")
}

///|
test "missing: sin, cos, tan" {
  inspect(test_feature("sin", "0"), content="Number(0)")
  inspect(test_feature("cos", "0"), content="Number(1)")
  inspect(test_feature("tan", "0"), content="Number(0)")
}

///|
test "missing: asin, acos, atan" {
  inspect(test_feature("asin", "0"), content="Number(0)")
  inspect(test_feature("acos", "1"), content="Number(0)")
  inspect(test_feature("atan", "0"), content="Number(0)")
}
