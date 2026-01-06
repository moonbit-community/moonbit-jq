///|
/// jq-compat tests for string helpers

///|
test "jq compat: split keeps empty segments" {
  let results = jq_eval("split(\"/\")", "\"a/b//c/\"")
  @json.inspect(results, content=[["a", "b", "", "c", ""]])
}

///|
test "jq compat: ltrimstr removes prefix only" {
  @json.inspect(jq_eval("ltrimstr(\"foo\")", "\"foobar\""), content=["bar"])
  @json.inspect(jq_eval("ltrimstr(\"bar\")", "\"foobar\""), content=["foobar"])
}

///|
test "jq compat: rtrimstr removes suffix only" {
  @json.inspect(jq_eval("rtrimstr(\"bar\")", "\"foobar\""), content=["foo"])
  @json.inspect(jq_eval("rtrimstr(\"baz\")", "\"foobar\""), content=["foobar"])
}

///|
test "jq compat: ascii_upcase/downcase only affects ASCII" {
  @json.inspect(jq_eval("ascii_downcase", "\"AbÇ\""), content=["abÇ"])
  @json.inspect(jq_eval("ascii_upcase", "\"AbÇ\""), content=["ABÇ"])
}
