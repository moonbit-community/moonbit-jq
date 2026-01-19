///|
/// Test built-ins: length, keys, type
test "integration: built-in functions" {
  json_inspect(jq("length", "[1,2,3,4,5]"), content=[5])
  json_inspect(jq("length", "\"hello\""), content=[5])
  json_inspect(jq("keys", "{\"b\": 1, \"a\": 2}"), content=[["b", "a"]])
  json_inspect(jq("type", "42"), content=["number"])
  json_inspect(jq("type", "\"hi\""), content=["string"])
}

///|
/// Test map function
test "integration: map function" {
  json_inspect(jq("map(. + 10)", "[1, 2, 3]"), content=[[11, 12, 13]])
  json_inspect(jq("map(. * 2)", "[5, 10, 15]"), content=[[10, 20, 30]])
}

///|
/// Test select function
test "integration: select function" {
  json_inspect(jq(".[] | select(. > 3)", "[1, 2, 3, 4, 5]"), content=[4, 5])
  json_inspect(jq(".[] | select(. < 0)", "[1, 2, 3]"), content=[])
}

///|
/// Test array functions
test "integration: array functions" {
  json_inspect(jq("sort", "[3, 1, 4, 1, 5, 9, 2, 6]"), content=[
    [1, 1, 2, 3, 4, 5, 6, 9],
  ])
  json_inspect(jq("reverse", "[1, 2, 3]"), content=[[3, 2, 1]])
  json_inspect(jq("unique", "[1, 2, 1, 3, 2]"), content=[[1, 2, 3]])
}

///|
/// Test numeric functions
test "integration: numeric functions" {
  json_inspect(jq("add", "[1, 2, 3, 4, 5]"), content=[15])
  json_inspect(jq("min", "[5, 2, 8, 1]"), content=[1])
  json_inspect(jq("max", "[5, 2, 8, 1]"), content=[8])
  json_inspect(jq("floor", "3.7"), content=[3])
  json_inspect(jq("sqrt", "16"), content=[4])
}
