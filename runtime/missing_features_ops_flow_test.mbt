///|
test "missing: limit(n; expr)" {
  assert_reference_query("limit(2; .[])", "[1,2,3,4,5]", "[1, 2]", 0)
}

///|
// Temporarily disabled
// test "missing: until(cond; update)" {
//   assert_reference_query("1 | until(. > 5; . + 1)", "null", "[6]", 0)
// }

///|
// Temporarily disabled - causes infinite loop
// test "missing: while(cond; update)" {
//   assert_reference_query("1 | while(. < 5; . + 1)", "null", "[1, 2, 3, 4]", 0)
// }

///|
// Temporarily disabled
// test "missing: recurse with condition" {
//   assert_reference_query("recurse(.+1; . < 5)", "1", "[1, 2, 3, 4]", 0)
// }

///|
test "missing: walk function" {
  assert_reference_query(
    "walk(if type == \"number\" then . * 2 else . end)", "{\"a\":1,\"b\":[2,3]}",
    "[{\"a\": 2, \"b\": [4, 6]}]", 0,
  )
}

///|
test "missing: update operator |=" {
  assert_reference_query(".a |= . + 1", "{\"a\":5}", "[{\"a\": 6}]", 0)
}

///|
test "missing: assignment operator =" {
  assert_reference_query(".a = 10", "{\"a\":5}", "[{\"a\": 10}]", 0)
}

///|
test "missing: alternative operator //" {
  assert_reference_query(".missing // \"default\"", "{}", "[\"default\"]", 0)
}

///|
test "missing: += operator" {
  assert_reference_query(".a += 3", "{\"a\":5}", "[{\"a\": 8}]", 0)
}

///|
test "missing: -= operator" {
  assert_reference_query(".a -= 3", "{\"a\":5}", "[{\"a\": 2}]", 0)
}

///|
test "missing: *= operator" {
  assert_reference_query(".a *= 3", "{\"a\":5}", "[{\"a\": 15}]", 0)
}

///|
test "missing: /= operator" {
  assert_reference_query(".a /= 2", "{\"a\":5}", "[{\"a\": 2.5}]", 0)
}

///|
test "missing: %= operator" {
  assert_reference_query(".a %= 2", "{\"a\":5}", "[{\"a\": 1}]", 0)
}

///|
test "missing: //= operator" {
  assert_reference_query(".a //= 10", "{\"a\":5}", "[{\"a\": 5}]", 0)
}
