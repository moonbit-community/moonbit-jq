///|
test "missing: @base64 format" {
  assert_reference_query("@base64", "\"hello\"", "[\"aGVsbG8=\"]", 0)
}

///|
test "missing: @base64d format" {
  assert_reference_query("@base64d", "\"aGVsbG8=\"", "[\"hello\"]", 0)
}

///|
test "missing: @uri format" {
  assert_reference_query("@uri", "\"hello world\"", "[\"hello%20world\"]", 0)
}

///|
test "missing: @csv format" {
  assert_reference_query("@csv", "[[1,2,3]]", "[]", 5)
}

///|
test "missing: @json format" {
  assert_reference_query("@json", "{\"a\":1}", "[\"{\\\"a\\\":1}\"]", 0)
}

///|
test "missing: @html format" {
  assert_reference_query("@html", "\"<div>\"", "[\"&lt;div&gt;\"]", 0)
}

///|
test "missing: @text format" {
  assert_reference_query("@text", "\"hello\"", "[\"hello\"]", 0)
}

///|
test "missing: test(regex)" {
  debug_inspect(
    test_feature(".text | test(\"^hello\")", "{\"text\":\"hello world\"}"),
    content=(
      #|"False"
    ),
  )
}

///|
test "missing: match(regex)" {
  debug_inspect(
    test_feature(".text | match(\"[0-9]+\")", "{\"text\":\"abc123def\"}"),
    content=(
      #|""
    ),
  )
}

///|
test "missing: capture(regex)" {
  debug_inspect(
    test_feature(
      ".text | capture(\"(?<num>[0-9]+)\")", "{\"text\":\"abc123def\"}",
    ),
    content=(
      #|"Object({})"
    ),
  )
}

///|
test "missing: splits(regex)" {
  debug_inspect(
    test_feature(".text | splits(\" +\")", "{\"text\":\"hello   world\"}"),
    content=(
      #|"String(\"hello   world\")"
    ),
  )
}

///|
test "missing: sub(regex; replacement)" {
  assert_reference_query(
    ".text | sub(\"world\"; \"MoonBit\")", "{\"text\":\"hello world\"}", "[\"hello MoonBit\"]",
    0,
  )
}

///|
test "missing: gsub(regex; replacement)" {
  assert_reference_query(
    ".text | gsub(\"o\"; \"0\")", "{\"text\":\"hello world\"}", "[\"hell0 w0rld\"]",
    0,
  )
}
