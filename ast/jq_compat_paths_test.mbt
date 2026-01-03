///|
/// jq-compat tests for paths

///|
test "jq compat: paths order matches jq" {
  let input : String =
    #|{
    #|  "a": [1, 2],
    #|  "b": { "c": 3 }
    #|}
  let results = jq_eval("paths", input)
  @json.inspect(results, content=[["a"], ["a", 0], ["a", 1], ["b"], ["b", "c"]])
}
