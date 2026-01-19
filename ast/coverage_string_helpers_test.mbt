///|
test "coverage: more string search helpers" {
  json_inspect(coverage_eval("index(\"foo\")", "\"foobar\""), content=[0])
  json_inspect(coverage_eval("indices(\"o\")", "\"foobar\""), content=[[]])
}

///|
test "coverage: @html escapes ampersand and quotes" {
  json_inspect(coverage_eval("@html", "\"&\\\"'\""), content=[
    "&amp;&quot;&#39;",
  ])
}
