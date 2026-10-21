///|
/// Corner case tests for recursive functions

///|
test "corner: recursive function with base case" {
  assert_reference_query(
    "def sum: if length == 0 then 0 else .[0] + (.[1:] | sum) end; sum", "[1,2,3,4,5]",
    "[15]", 0,
  )
}

///|
test "corner: mutually recursive functions" {
  assert_reference_query(
    "def even: if . == 0 then true elif . == 1 then false else (. - 2) | even end; def odd: if . == 0 then false elif . == 1 then true else (. - 2) | odd end; even",
    "6", "[true]", 0,
  )
}
