///|
/// Expected values in these tests come from jq 1.7.1, including old snapshots
/// that previously accepted truncation, unbound parameters, or invalid indexing.
fn assert_reference_query(
  query : String,
  input : String,
  expected : String,
  status : Int32,
) -> Unit raise {
  let json = @json.parse(input)
  let plan = @runtime.compile(@parser.parse(query)) catch {
    _ => {
      assert_eq(status, 3, msg=query)
      return
    }
  }
  assert_true(status != 3, msg=query)
  let out : Array[Json] = []
  let mut actual = 0
  let stream = @runtime.eval(plan, json)
  for event in stream {
    match event {
      Ok(v) => out.push(v)
      Err(_) => {
        actual = 5
        assert_true(stream.next() is None)
        break
      }
    }
  }
  assert_eq(Json::array(out), @json.parse(expected), msg=query)
  assert_eq(actual, status, msg=query)
}
