///|
/// Comprehensive tests for path and array operations

// ============================================================================
// Path Manipulation Tests
// ============================================================================

///|
test "paths: all paths in nested structure" {
  assert_reference_query(
    "paths", "{\"a\":{\"b\":1,\"c\":2}}", "[[\"a\"], [\"a\", \"b\"], [\"a\", \"c\"]]",
    0,
  )
  debug_query(
    InputQuery(
      query="paths",
      input=(
        #| {"a" : {"b":1,"c":2}, "d":[3,4]}
      ),
    ),
    content=(
      #|Array([String("a")]), Array([String("a"), String("b")]), Array([String("a"), String("c")]), Array([String("d")]), Array([String("d"), Number(0)]), Array([String("d"), Number(1)])
    ),
  )
}

///|
test "leaf_paths: only leaf paths" {
  debug_inspect(
    test_query("leaf_paths", "{\"a\":{\"b\":1,\"c\":2},\"d\":3}"),
    content=(
      #|"Array([String(\"a\"), String(\"b\")]), Array([String(\"a\"), String(\"c\")]), Array([String(\"d\")])"
    ),
  )
}

///|
test "getpath: retrieve value at path" {
  assert_reference_query(
    "getpath([\"a\",\"b\"])", "{\"a\":{\"b\":42,\"c\":10}}", "[42]", 0,
  )
}

///|
test "setpath: set value at path" {
  assert_reference_query(
    "setpath([\"a\",\"b\"]; 99)", "{\"a\":{\"b\":1,\"c\":2}}", "[{\"a\": {\"b\": 99, \"c\": 2}}]",
    0,
  )
}

///|
test "delpaths: delete multiple paths" {
  assert_reference_query(
    "delpaths([[\"a\",\"b\"],[\"c\"]])", "{\"a\":{\"b\":1,\"d\":2},\"c\":3,\"e\":4}",
    "[{\"a\": {\"d\": 2}, \"e\": 4}]", 0,
  )
}

// ============================================================================
// Advanced Array Operations
// ============================================================================

///|
test "nth: get specific element" {
  assert_reference_query("nth(2)", "[10,20,30,40,50]", "[30]", 0)
}

///|
test "nth: negative index" {
  assert_reference_query("nth(-1)", "[10,20,30,40,50]", "[50]", 0)
}

///|
test "rindex: find last occurrence" {
  assert_reference_query("rindex(2)", "[1,2,3,2,1]", "[3]", 0)
}

///|
test "limit: restrict output count" {
  assert_reference_query(
    "limit(3; .[])", "[1,2,3,4,5,6,7,8,9,10]", "[1, 2, 3]", 0,
  )
}

///|
test "walk: transform all values" {
  assert_reference_query(
    "walk(if type == \"number\" then . * 2 else . end)", "{\"a\":1,\"b\":{\"c\":2}}",
    "[{\"a\": 2, \"b\": {\"c\": 4}}]", 0,
  )
}
