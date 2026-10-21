///|
/// Comprehensive tests for user-defined functions

// ============================================================================
// User-Defined Functions Tests
// ============================================================================

///|
test "def: simple function no params" {
  assert_reference_query("def double: . * 2; double", "5", "[10]", 0)
}

///|
test "def: function with parameter" {
  assert_reference_query("def add(x): . + x; add(10)", "5", "[15]", 0)
}

///|
test "def: multiple parameters" {
  assert_reference_query(
    "def multiply(x; y): . * x * y; multiply(3; 4)", "2", "[24]", 0,
  )
}

///|
test "def: recursive function" {
  assert_reference_query(
    "def factorial: if . <= 1 then 1 else . * ((. - 1) | factorial) end; factorial",
    "5", "[120]", 0,
  )
}

///|
test "def: fibonacci" {
  assert_reference_query(
    "def fib: if . <= 1 then . else ((. - 1) | fib) + ((. - 2) | fib) end; fib",
    "10", "[55]", 0,
  )
}

///|
test "def: function calling another function" {
  assert_reference_query(
    "def square: . * .; def sum_of_squares(x): square + (x | square); sum_of_squares(4)",
    "3", "[25]", 0,
  )
}

///|
test "def: function with array manipulation" {
  assert_reference_query(
    "def first_two: [.[0], .[1]]; first_two", "[1,2,3,4,5]", "[[1, 2]]", 0,
  )
}

// ============================================================================
// Complex Scenarios with Functions
// ============================================================================

///|
test "complex: nested function with interpolation" {
  assert_reference_query(
    "def greet(name): \"Hello \\(name), you are \\(. | tostring) years old!\"; greet(\"Alice\")",
    "25", "[\"Hello Alice, you are 25 years old!\"]", 0,
  )
}

///|
test "complex: array transformation with custom function" {
  assert_reference_query(
    "def double: . * 2; [.[] | double]", "[1,2,3,4,5]", "[[2, 4, 6, 8, 10]]", 0,
  )
}

///|
test "complex: recursive tree walk" {
  assert_reference_query(
    "def sum_all: if type == \"number\" then . elif type == \"array\" then [.[] | sum_all] | add else 0 end; sum_all",
    "[1,[2,3],[4,[5,6]]]", "[21]", 0,
  )
}
