///|
/// Test control flow
test "integration: control flow" {
  assert_reference_query(
    "if . > 5 then \"big\" else \"small\" end", "10", "[\"big\"]", 0,
  )
  assert_reference_query(
    "if . > 5 then \"big\" else \"small\" end", "2", "[\"small\"]", 0,
  )
}

///|
/// Test optional operator
test "integration: optional operator" {
  assert_reference_query(".a.b.c?", "{}", "[null]", 0)
  assert_reference_query(".x?", "{\"x\": 42}", "[42]", 0)
}

///|
/// Test alternative operator
test "integration: alternative operator" {
  assert_reference_query(".a // .b", "{\"a\": null, \"b\": 10}", "[10]", 0)
  assert_reference_query(".a // .b", "{\"a\": 5, \"b\": 10}", "[5]", 0)
  assert_reference_query(".missing // \"default\"", "{}", "[\"default\"]", 0)
}

///|
/// Test error handling
test "integration: error propagation" {
  assert_jq_error("1 / 0", "null")
}
