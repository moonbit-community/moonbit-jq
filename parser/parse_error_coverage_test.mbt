///|
fn parse_err(query : String) -> Bool {
  try @parser.parse(query) catch {
    _ => true
  } noraise {
    _ => false
  }
}

///|
fn parse_ok(query : String) -> Unit raise {
  ignore(@parser.parse(query))
}

///|
test "coverage: generic syntax accepts string-arg builtins" {
  parse_ok("test(1)")
  parse_ok("match(1)")
  parse_ok("capture(1)")
  parse_ok("splits(1)")
  parse_ok("scan(1)")
}

///|
test "coverage: generic syntax accepts sub/gsub argument types" {
  parse_ok("sub(1; \"x\")")
  parse_ok("sub(\"x\"; 1)")
  parse_ok("gsub(1; \"x\")")
  parse_ok("gsub(\"x\"; 1)")
}

///|
test "coverage: parse errors for reduce/foreach variable binding" {
  assert_true(parse_err("reduce .[] as x (0; . + $x)"))
  assert_true(parse_err("foreach .[] as x (0; . + $x)"))
}

///|
test "coverage: parse errors for function definitions" {
  assert_true(parse_err("def : .; ."))
  assert_true(parse_err("def f(1): .; f"))
  assert_true(parse_err("def f(a; 1): .; f(1;2)"))
}

///|
test "coverage: generic syntax accepts limit argument" {
  parse_ok("limit(\"2\"; .)")
}

///|
test "coverage: parse field access variants" {
  parse_ok("1.[0]")
  assert_true(parse_err("1. ."))
  parse_ok("1.")
}

///|
test "coverage: parse object edge cases" {
  parse_ok("{\"a\":1,}")
  assert_true(parse_err("{1:2}"))
}

///|
test "coverage: parse interpolation lex error" {
  assert_true(parse_err("\"x \\(~)\""))
}

///|
test "coverage: parse recurse builtin" {
  parse_ok("recurse")
}

///|
test "coverage: parse errors for as and index edge cases" {
  assert_true(parse_err(". as 1 | ."))
  assert_true(parse_err(".[,]"))
  assert_true(parse_err(".[1,]"))
  assert_true(parse_err(".[-]"))
}

///|
test "coverage: generic syntax accepts builtin argument validation" {
  parse_ok("split(1)")
  parse_ok("join(1)")
  parse_ok("startswith(1)")
  parse_ok("endswith(1)")
  parse_ok("has(true)")
  parse_ok("range(.a)")
  parse_ok("any(.[])")
  parse_ok("all(.[])")
  parse_ok("ltrimstr(1)")
  parse_ok("rtrimstr(1)")
  parse_ok("nth(\"x\")")
}

///|
test "coverage: parse errors for reduce/foreach missing as" {
  assert_true(parse_err("reduce .[] (0; . + $x)"))
  assert_true(parse_err("foreach .[] (0; . + $x)"))
}
