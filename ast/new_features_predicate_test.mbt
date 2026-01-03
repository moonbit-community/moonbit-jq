///|
test "any function" {
  let result = run_jq("any", "[true,false,false]")
  inspect(result, content="Ok([True])")
  let result2 = run_jq("any", "[false,false]")
  inspect(result2, content="Ok([False])")
}

///|
test "all function" {
  let result = run_jq("all", "[true,true,true]")
  inspect(result, content="Ok([True])")
  let result2 = run_jq("all", "[true,false,true]")
  inspect(result2, content="Ok([False])")
}
