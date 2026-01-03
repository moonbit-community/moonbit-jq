///|
test "coverage: update path navigates through arrays" {
  let input : String =
    #|{
    #|  "a": [1]
    #|}
  @json.inspect(coverage_eval(".a[0] |= . + 1", input), content=[{ "a": [2] }])
}
