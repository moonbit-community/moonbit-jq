///|
test "stream: construction performs no evaluation" {
  // Neither expression can reach a first output. Merely creating the iterator
  // must still return immediately, without running or collecting the query.
  let never = @moonjq.parse("repeat(empty)")
  let _ = never.eval(null)
  let error = @moonjq.parse("error({code: 7})")
  let _ = error.eval(null)
}

///|
test "stream: null, empty, and terminal errors are distinct" {
  let stream = @moonjq.parse("null, empty, 1, error({code: 7}), 2").eval(null)
  assert_true(stream.next() is Some(Ok(Null)))
  assert_true(stream.next() is Some(Ok(Number(1, ..))))
  guard stream.next() is Some(Err(err)) else { fail("expected explicit error") }
  assert_eq(err.value(), { "code": 7 })
  guard err.span() is Some(span) else { fail("expected source position") }
  assert_eq(span.start, 16)
  assert_eq(span.end, 32)
  assert_true(stream.next() is None)
  assert_true(stream.next() is None)
}

///|
test "stream: repeated and interleaved evaluations own their state" {
  let query = @moonjq.parse("def twice(f): f,f; twice(. + 1)")
  let a = query.eval(Json::number(10))
  let b = query.eval(Json::number(20))
  assert_true(a.next() is Some(Ok(Number(11, ..))))
  assert_true(b.next() is Some(Ok(Number(21, ..))))
  assert_true(a.next() is Some(Ok(Number(11, ..))))
  assert_true(a.next() is None)
  assert_true(b.next() is Some(Ok(Number(21, ..))))
  assert_true(b.next() is None)
  assert_eq(query.eval_all(Json::number(10)), [
    Json::number(11),
    Json::number(11),
  ])
}

///|
test "stream: logs skip malformed input and preserve terminal query errors" {
  let query = @moonjq.parse("., if . == 2 then error({bad:.}) else empty end")
  let stream = query.eval_logs("invalid\n1\r\n{\n2\n3\n")
  assert_true(stream.next() is Some(Ok(Number(1, ..))))
  assert_true(stream.next() is Some(Ok(Number(2, ..))))
  guard stream.next() is Some(Err(err)) else {
    fail("expected log query error")
  }
  assert_eq(err.value(), { "bad": 2 })
  assert_true(stream.next() is None)
}

///|
test "stream: eager consumers raise the original JSON error" {
  let query = @moonjq.parse("1, error({bad: true}), 2")
  try query.eval_all(null) catch {
    err => assert_eq(err.value(), { "bad": true })
  } noraise {
    _ => fail("expected failure")
  }
}

///|
test "stream: recursive filters use execution frames instead of the host stack" {
  let query = @moonjq.parse(
    "def down: if . == 0 then . else (. - 1) | down end; down",
  )
  assert_eq(query.eval_all(Json::number(5000)), [Json::number(0)])
}

///|
test "stream: interpolation equals ordinary conversion and concatenation" {
  for
    source in [
      Json::null(),
      Json::number(3),
      Json::string("😀"),
      { "a": [1, 2] },
    ] {
    for expression in [".", "empty", "(1,2)", "(. , [.] , {end:.})"] {
      let interpolation = "\"a\\(" + expression + ")b\""
      let expansion = "\"a\" + ((" + expression + ")|tostring) + \"b\""
      assert_eq(
        @moonjq.run(interpolation, source.stringify()),
        @moonjq.run(expansion, source.stringify()),
      )
    }
  }
}
