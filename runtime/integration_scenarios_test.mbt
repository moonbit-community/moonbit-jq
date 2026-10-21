///|
/// Test complex real-world query
test "integration: filter and transform" {
  let data : String =
    #|{
    #|  "users": [
    #|    { "name": "Alice", "age": 25, "active": true },
    #|    { "name": "Bob", "age": 15, "active": false },
    #|    { "name": "Charlie", "age": 30, "active": true }
    #|  ]
    #|}
  // Filter users who are active
  json_inspect(jq(".users | .[] | select(.active) | .name", data), content=[
    "Alice", "Charlie",
  ])
}

///|
/// Test recursive descent
test "integration: recursive descent" {
  let data : String =
    #|{
    #|  "a": { "b": 1, "c": 2 }
    #|}
  let results = jq("..", data)
  // Should yield the input object first
  json_inspect(results[0], content={ "a": { "b": 1, "c": 2 } })
}

///|
/// Test complex nested query
test "integration: complex nested query" {
  let data : String =
    #|{
    #|  "store": {
    #|    "books": [
    #|      { "title": "Book A", "price": 10 },
    #|      { "title": "Book B", "price": 15 }
    #|    ]
    #|  }
    #|}
  json_inspect(jq(".store.books | .[] | .title", data), content=[
    "Book A", "Book B",
  ])
  json_inspect(jq(".store.books | map(.price)", data), content=[[10, 15]])
}
