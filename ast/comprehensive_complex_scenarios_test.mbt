///|
/// Comprehensive tests for complex scenarios

///|
test "complex: data transformation pipeline" {
  debug_inspect(
    test_query(
      ".users | map({name: .name, email: .email}) | sort_by(.name)", "{\"users\":[{\"name\":\"Bob\",\"email\":\"bob@test.com\",\"age\":30},{\"name\":\"Alice\",\"email\":\"alice@test.com\",\"age\":25}]}",
    ),
    content=(
      #|"Array(\n  [\n    Object({ \"name\": String(\"Bob\"), \"email\": String(\"bob@test.com\") }),\n    Object({ \"name\": String(\"Alice\"), \"email\": String(\"alice@test.com\") }),\n  ],\n)"
    ),
  )
}

///|
test "complex: conditional aggregation" {
  debug_inspect(
    test_query("[.[] | select(. > 5)] | add", "[1,3,10,7,2,8]"),
    content=(
      #|"Number(25)"
    ),
  )
}

///|
test "complex: grouped operations" {
  debug_inspect(
    test_query(
      "group_by(.type) | map({type: .[0].type, count: length})", "[{\"type\":\"A\",\"val\":1},{\"type\":\"B\",\"val\":2},{\"type\":\"A\",\"val\":3},{\"type\":\"B\",\"val\":4}]",
    ),
    content=(
      #|"Array(\n  [\n    Object({ \"type\": String(\"A\"), \"count\": Number(2) }),\n    Object({ \"type\": String(\"B\"), \"count\": Number(2) }),\n  ],\n)"
    ),
  )
}
