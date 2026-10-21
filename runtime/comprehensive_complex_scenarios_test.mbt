///|
/// Comprehensive tests for complex scenarios

///|
test "complex: data transformation pipeline" {
  assert_reference_query(
    ".users | map({name: .name, email: .email}) | sort_by(.name)", "{\"users\":[{\"name\":\"Bob\",\"email\":\"bob@test.com\",\"age\":30},{\"name\":\"Alice\",\"email\":\"alice@test.com\",\"age\":25}]}",
    "[[{\"name\": \"Alice\", \"email\": \"alice@test.com\"}, {\"name\": \"Bob\", \"email\": \"bob@test.com\"}]]",
    0,
  )
}

///|
test "complex: conditional aggregation" {
  assert_reference_query(
    "[.[] | select(. > 5)] | add", "[1,3,10,7,2,8]", "[25]", 0,
  )
}

///|
test "complex: grouped operations" {
  assert_reference_query(
    "group_by(.type) | map({type: .[0].type, count: length})", "[{\"type\":\"A\",\"val\":1},{\"type\":\"B\",\"val\":2},{\"type\":\"A\",\"val\":3},{\"type\":\"B\",\"val\":4}]",
    "[[{\"type\": \"A\", \"count\": 2}, {\"type\": \"B\", \"count\": 2}]]", 0,
  )
}
