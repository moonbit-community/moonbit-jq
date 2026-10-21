///|
test "missing: values function" {
  assert_reference_query("values", "[1,2,null,3]", "[[1, 2, null, 3]]", 0)
}

///|
test "missing: nth(n)" {
  assert_reference_query("nth(1)", "[10,20,30]", "[20]", 0)
}

///|
test "missing: rindex" {
  assert_reference_query("[1,2,3,2,1] | rindex(2)", "null", "[3]", 0)
}

///|
test "missing: paths" {
  assert_reference_query(
    "paths", "{\"a\":{\"b\":1},\"c\":[2,3]}", "[[\"a\"], [\"a\", \"b\"], [\"c\"], [\"c\", 0], [\"c\", 1]]",
    0,
  )
}

///|
test "missing: leaf_paths" {
  debug_inspect(
    test_feature("leaf_paths", "{\"a\":{\"b\":1},\"c\":[2,3]}"),
    content=(
      #|"Array([String(\"a\"), String(\"b\")])\nArray([String(\"c\"), Number(0)])\nArray([String(\"c\"), Number(1)])"
    ),
  )
}

///|
test "missing: getpath" {
  assert_reference_query(
    "getpath([\"a\",\"b\"])", "{\"a\":{\"b\":42}}", "[42]", 0,
  )
}

///|
test "missing: setpath" {
  assert_reference_query(
    "setpath([\"a\",\"b\"]; 99)", "{\"a\":{\"b\":42}}", "[{\"a\": {\"b\": 99}}]",
    0,
  )
}

///|
test "missing: delpaths" {
  assert_reference_query(
    "delpaths([[\"a\",\"b\"]])", "{\"a\":{\"b\":42,\"c\":1}}", "[{\"a\": {\"c\": 1}}]",
    0,
  )
}
