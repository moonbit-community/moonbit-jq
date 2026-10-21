///|
test "missing: user-defined functions" {
  assert_reference_query("def double: . * 2; double", "5", "[10]", 0)
}

///|
test "missing: user-defined functions with params" {
  assert_reference_query("def add(x): . + x; add(10)", "5", "[15]", 0)
}

///|
test "missing: recursive user-defined functions" {
  assert_reference_query(
    "def factorial: if . <= 1 then 1 else . * ((. - 1) | factorial) end; factorial",
    "5", "[120]", 0,
  )
}

///|
test "missing: comments in query" {
  assert_reference_query("# comment\n. + 1", "1", "[2]", 0)
}

///|
test "missing: multiline queries" {
  assert_reference_query(".\n+\n1", "1", "[2]", 0)
}
