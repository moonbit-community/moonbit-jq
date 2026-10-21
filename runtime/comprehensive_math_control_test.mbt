///|
/// Comprehensive tests for math and control flow

// ============================================================================
// Mathematical Operations
// ============================================================================

///|
test "pow: power function" {
  assert_reference_query("pow(2; 10)", "null", "[1024]", 0)
}

///|
test "log: natural logarithm" {
  assert_reference_query("log", "2.718281828", "[0.9999999998311266]", 0)
}

///|
test "exp: exponential" {
  assert_reference_query("exp", "1", "[2.718281828459045]", 0)
}

///|
test "sin: sine" {
  assert_reference_query("sin", "0", "[0]", 0)
}

///|
test "cos: cosine" {
  assert_reference_query("cos", "0", "[1]", 0)
}

///|
test "sqrt: square root" {
  assert_reference_query("sqrt", "16", "[4]", 0)
}

///|
test "floor: floor function" {
  assert_reference_query("floor", "3.7", "[3]", 0)
}

///|
test "ceil: ceiling function" {
  assert_reference_query("ceil", "3.2", "[4]", 0)
}

// ============================================================================
// Control Flow Tests
// ============================================================================

///|
test "if-then-else: basic conditional" {
  assert_reference_query(
    "if . > 10 then \"big\" else \"small\" end", "15", "[\"big\"]", 0,
  )
}

///|
test "if-then-elif-else: multiple conditions" {
  assert_reference_query(
    "if . < 0 then \"negative\" elif . == 0 then \"zero\" else \"positive\" end",
    "5", "[\"positive\"]", 0,
  )
}

///|
test "try-catch: error handling" {
  assert_reference_query("try .x catch \"error\"", "{}", "[null]", 0)
}

///|
test "alternative operator: fallback" {
  assert_reference_query(".x // 42", "{\"y\":10}", "[42]", 0)
}

///|
test "alternative operator: with value" {
  assert_reference_query(".x // 42", "{\"x\":5}", "[5]", 0)
}
