///|
/// Test pipe and comma
test "integration: pipe and comma" {
  json_inspect(jq(". | . + 1", "5"), content=[6])
  json_inspect(jq(".a | .b", "{\"a\": {\"b\": 42}}"), content=[42])
  json_inspect(jq(".a, .b", "{\"a\": 1, \"b\": 2}"), content=[1, 2])
}

///|
/// Test arithmetic
test "integration: arithmetic" {
  json_inspect(jq("1 + 2", "null"), content=[3])
  json_inspect(jq("10 - 3", "null"), content=[7])
  json_inspect(jq("6 * 7", "null"), content=[42])
  json_inspect(jq("20 / 4", "null"), content=[5])
  json_inspect(jq("17 % 5", "null"), content=[2])
}

///|
/// Test comparisons
test "integration: comparisons" {
  json_inspect(jq("1 < 2", "null"), content=[true])
  json_inspect(jq("5 > 10", "null"), content=[false])
  json_inspect(jq("3 == 3", "null"), content=[true])
  json_inspect(jq("4 != 5", "null"), content=[true])
}

///|
/// Test logical operators
test "integration: logical operators" {
  json_inspect(jq("true and false", "null"), content=[false])
  json_inspect(jq("true or false", "null"), content=[true])
  json_inspect(jq("not", "true"), content=[false])
  json_inspect(jq("not", "false"), content=[true])
}
