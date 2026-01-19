///|
/// Test control flow
test "integration: control flow" {
  json_inspect(jq("if . > 5 then \"big\" else \"small\" end", "10"), content=[
    "big",
  ])
  json_inspect(jq("if . > 5 then \"big\" else \"small\" end", "2"), content=[
    "small",
  ])
}

///|
/// Test optional operator
test "integration: optional operator" {
  json_inspect(jq(".a.b.c?", "{}"), content=[null])
  json_inspect(jq(".x?", "{\"x\": 42}"), content=[42])
}

///|
/// Test alternative operator
test "integration: alternative operator" {
  json_inspect(jq(".a // .b", "{\"a\": null, \"b\": 10}"), content=[10])
  json_inspect(jq(".a // .b", "{\"a\": 5, \"b\": 10}"), content=[5])
  json_inspect(jq(".missing // \"default\"", "{}"), content=["default"])
}

///|
/// Test error handling
test "integration: error propagation" {
  // Division by zero should raise error
  let result = try? jq("1 / 0", "null")
  assert_true(result is Err(_))
}
