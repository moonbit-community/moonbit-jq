///|
// Generated exclusively from tests/semantics/jq-1.7.1.json by reference.mjs.
fn reference_case(
  query : String,
  input : String,
  expected : String,
  status : Int32,
) -> Unit raise {
  let compiled = @moonjq.parse(query) catch {
    _ => {
      assert_eq(status, 3, msg=query)
      return
    }
  }
  assert_true(status != 3, msg=query)
  let stream = compiled.eval(@json.parse(input))
  let outputs : Array[Json] = []
  let mut actual_status = 0
  for event in stream {
    match event {
      Ok(v) => outputs.push(v)
      Err(_) => {
        actual_status = 5
        assert_true(stream.next() is None, msg=query)
        break
      }
    }
  }
  assert_eq(Json::array(outputs), @json.parse(expected), msg=query)
  assert_eq(actual_status, status, msg=query)
}

///|
test "reference jq 1.7.1 000: field" {
  reference_case(".true", "{\"true\": 7, \"a\": {\"true\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 001: field" {
  reference_case(".a.true", "{\"true\": 7, \"a\": {\"true\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 002: field" {
  reference_case(".\"true\"", "{\"true\": 7, \"a\": {\"true\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 003: field" {
  reference_case(
    "{true: 1}", "{\"true\": 7, \"a\": {\"true\": 8}}", "[{\"true\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 004: field" {
  reference_case(".false", "{\"false\": 7, \"a\": {\"false\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 005: field" {
  reference_case(".a.false", "{\"false\": 7, \"a\": {\"false\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 006: field" {
  reference_case(
    ".\"false\"", "{\"false\": 7, \"a\": {\"false\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 007: field" {
  reference_case(
    "{false: 1}", "{\"false\": 7, \"a\": {\"false\": 8}}", "[{\"false\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 008: field" {
  reference_case(".null", "{\"null\": 7, \"a\": {\"null\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 009: field" {
  reference_case(".a.null", "{\"null\": 7, \"a\": {\"null\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 010: field" {
  reference_case(".\"null\"", "{\"null\": 7, \"a\": {\"null\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 011: field" {
  reference_case(
    "{null: 1}", "{\"null\": 7, \"a\": {\"null\": 8}}", "[{\"null\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 012: field" {
  reference_case(".and", "{\"and\": 7, \"a\": {\"and\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 013: field" {
  reference_case(".a.and", "{\"and\": 7, \"a\": {\"and\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 014: field" {
  reference_case(".\"and\"", "{\"and\": 7, \"a\": {\"and\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 015: field" {
  reference_case(
    "{and: 1}", "{\"and\": 7, \"a\": {\"and\": 8}}", "[{\"and\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 016: field" {
  reference_case(".or", "{\"or\": 7, \"a\": {\"or\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 017: field" {
  reference_case(".a.or", "{\"or\": 7, \"a\": {\"or\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 018: field" {
  reference_case(".\"or\"", "{\"or\": 7, \"a\": {\"or\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 019: field" {
  reference_case(
    "{or: 1}", "{\"or\": 7, \"a\": {\"or\": 8}}", "[{\"or\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 020: field" {
  reference_case(".not", "{\"not\": 7, \"a\": {\"not\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 021: field" {
  reference_case(".a.not", "{\"not\": 7, \"a\": {\"not\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 022: field" {
  reference_case(".\"not\"", "{\"not\": 7, \"a\": {\"not\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 023: field" {
  reference_case(
    "{not: 1}", "{\"not\": 7, \"a\": {\"not\": 8}}", "[{\"not\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 024: field" {
  reference_case(".if", "{\"if\": 7, \"a\": {\"if\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 025: field" {
  reference_case(".a.if", "{\"if\": 7, \"a\": {\"if\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 026: field" {
  reference_case(".\"if\"", "{\"if\": 7, \"a\": {\"if\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 027: field" {
  reference_case(
    "{if: 1}", "{\"if\": 7, \"a\": {\"if\": 8}}", "[{\"if\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 028: field" {
  reference_case(".then", "{\"then\": 7, \"a\": {\"then\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 029: field" {
  reference_case(".a.then", "{\"then\": 7, \"a\": {\"then\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 030: field" {
  reference_case(".\"then\"", "{\"then\": 7, \"a\": {\"then\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 031: field" {
  reference_case(
    "{then: 1}", "{\"then\": 7, \"a\": {\"then\": 8}}", "[{\"then\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 032: field" {
  reference_case(".else", "{\"else\": 7, \"a\": {\"else\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 033: field" {
  reference_case(".a.else", "{\"else\": 7, \"a\": {\"else\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 034: field" {
  reference_case(".\"else\"", "{\"else\": 7, \"a\": {\"else\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 035: field" {
  reference_case(
    "{else: 1}", "{\"else\": 7, \"a\": {\"else\": 8}}", "[{\"else\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 036: field" {
  reference_case(".elif", "{\"elif\": 7, \"a\": {\"elif\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 037: field" {
  reference_case(".a.elif", "{\"elif\": 7, \"a\": {\"elif\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 038: field" {
  reference_case(".\"elif\"", "{\"elif\": 7, \"a\": {\"elif\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 039: field" {
  reference_case(
    "{elif: 1}", "{\"elif\": 7, \"a\": {\"elif\": 8}}", "[{\"elif\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 040: field" {
  reference_case(".end", "{\"end\": 7, \"a\": {\"end\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 041: field" {
  reference_case(".a.end", "{\"end\": 7, \"a\": {\"end\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 042: field" {
  reference_case(".\"end\"", "{\"end\": 7, \"a\": {\"end\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 043: field" {
  reference_case(
    "{end: 1}", "{\"end\": 7, \"a\": {\"end\": 8}}", "[{\"end\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 044: field" {
  reference_case(".as", "{\"as\": 7, \"a\": {\"as\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 045: field" {
  reference_case(".a.as", "{\"as\": 7, \"a\": {\"as\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 046: field" {
  reference_case(".\"as\"", "{\"as\": 7, \"a\": {\"as\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 047: field" {
  reference_case(
    "{as: 1}", "{\"as\": 7, \"a\": {\"as\": 8}}", "[{\"as\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 048: field" {
  reference_case(".reduce", "{\"reduce\": 7, \"a\": {\"reduce\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 049: field" {
  reference_case(
    ".a.reduce", "{\"reduce\": 7, \"a\": {\"reduce\": 8}}", "[8]", 0,
  )
}

///|
test "reference jq 1.7.1 050: field" {
  reference_case(
    ".\"reduce\"", "{\"reduce\": 7, \"a\": {\"reduce\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 051: field" {
  reference_case(
    "{reduce: 1}", "{\"reduce\": 7, \"a\": {\"reduce\": 8}}", "[{\"reduce\": 1}]",
    0,
  )
}

///|
test "reference jq 1.7.1 052: field" {
  reference_case(
    ".foreach", "{\"foreach\": 7, \"a\": {\"foreach\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 053: field" {
  reference_case(
    ".a.foreach", "{\"foreach\": 7, \"a\": {\"foreach\": 8}}", "[8]", 0,
  )
}

///|
test "reference jq 1.7.1 054: field" {
  reference_case(
    ".\"foreach\"", "{\"foreach\": 7, \"a\": {\"foreach\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 055: field" {
  reference_case(
    "{foreach: 1}", "{\"foreach\": 7, \"a\": {\"foreach\": 8}}", "[{\"foreach\": 1}]",
    0,
  )
}

///|
test "reference jq 1.7.1 056: field" {
  reference_case(".try", "{\"try\": 7, \"a\": {\"try\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 057: field" {
  reference_case(".a.try", "{\"try\": 7, \"a\": {\"try\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 058: field" {
  reference_case(".\"try\"", "{\"try\": 7, \"a\": {\"try\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 059: field" {
  reference_case(
    "{try: 1}", "{\"try\": 7, \"a\": {\"try\": 8}}", "[{\"try\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 060: field" {
  reference_case(".catch", "{\"catch\": 7, \"a\": {\"catch\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 061: field" {
  reference_case(".a.catch", "{\"catch\": 7, \"a\": {\"catch\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 062: field" {
  reference_case(
    ".\"catch\"", "{\"catch\": 7, \"a\": {\"catch\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 063: field" {
  reference_case(
    "{catch: 1}", "{\"catch\": 7, \"a\": {\"catch\": 8}}", "[{\"catch\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 064: field" {
  reference_case(".def", "{\"def\": 7, \"a\": {\"def\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 065: field" {
  reference_case(".a.def", "{\"def\": 7, \"a\": {\"def\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 066: field" {
  reference_case(".\"def\"", "{\"def\": 7, \"a\": {\"def\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 067: field" {
  reference_case(
    "{def: 1}", "{\"def\": 7, \"a\": {\"def\": 8}}", "[{\"def\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 068: field" {
  reference_case(".label", "{\"label\": 7, \"a\": {\"label\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 069: field" {
  reference_case(".a.label", "{\"label\": 7, \"a\": {\"label\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 070: field" {
  reference_case(
    ".\"label\"", "{\"label\": 7, \"a\": {\"label\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 071: field" {
  reference_case(
    "{label: 1}", "{\"label\": 7, \"a\": {\"label\": 8}}", "[{\"label\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 072: field" {
  reference_case(".break", "{\"break\": 7, \"a\": {\"break\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 073: field" {
  reference_case(".a.break", "{\"break\": 7, \"a\": {\"break\": 8}}", "[8]", 0)
}

///|
test "reference jq 1.7.1 074: field" {
  reference_case(
    ".\"break\"", "{\"break\": 7, \"a\": {\"break\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 075: field" {
  reference_case(
    "{break: 1}", "{\"break\": 7, \"a\": {\"break\": 8}}", "[{\"break\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 076: field" {
  reference_case(".import", "{\"import\": 7, \"a\": {\"import\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 077: field" {
  reference_case(
    ".a.import", "{\"import\": 7, \"a\": {\"import\": 8}}", "[8]", 0,
  )
}

///|
test "reference jq 1.7.1 078: field" {
  reference_case(
    ".\"import\"", "{\"import\": 7, \"a\": {\"import\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 079: field" {
  reference_case(
    "{import: 1}", "{\"import\": 7, \"a\": {\"import\": 8}}", "[{\"import\": 1}]",
    0,
  )
}

///|
test "reference jq 1.7.1 080: field" {
  reference_case(
    ".include", "{\"include\": 7, \"a\": {\"include\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 081: field" {
  reference_case(
    ".a.include", "{\"include\": 7, \"a\": {\"include\": 8}}", "[8]", 0,
  )
}

///|
test "reference jq 1.7.1 082: field" {
  reference_case(
    ".\"include\"", "{\"include\": 7, \"a\": {\"include\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 083: field" {
  reference_case(
    "{include: 1}", "{\"include\": 7, \"a\": {\"include\": 8}}", "[{\"include\": 1}]",
    0,
  )
}

///|
test "reference jq 1.7.1 084: field" {
  reference_case(".module", "{\"module\": 7, \"a\": {\"module\": 8}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 085: field" {
  reference_case(
    ".a.module", "{\"module\": 7, \"a\": {\"module\": 8}}", "[8]", 0,
  )
}

///|
test "reference jq 1.7.1 086: field" {
  reference_case(
    ".\"module\"", "{\"module\": 7, \"a\": {\"module\": 8}}", "[7]", 0,
  )
}

///|
test "reference jq 1.7.1 087: field" {
  reference_case(
    "{module: 1}", "{\"module\": 7, \"a\": {\"module\": 8}}", "[{\"module\": 1}]",
    0,
  )
}

///|
test "reference jq 1.7.1 088: frontend" {
  reference_case(". 1", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 089: frontend" {
  reference_case(".a.", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 090: frontend" {
  reference_case(".a.)", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 091: frontend" {
  reference_case("\"\\(. 1)\"", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 092: frontend" {
  reference_case("\"\\(.a.)\"", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 093: frontend" {
  reference_case(".", "null", "[null]", 0)
}

///|
test "reference jq 1.7.1 094: frontend" {
  reference_case("1.", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 095: frontend" {
  reference_case("\"\\(empty)\"", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 096: frontend" {
  reference_case("\"\\((1,2))\"", "null", "[\"1\", \"2\"]", 0)
}

///|
test "reference jq 1.7.1 097: frontend" {
  reference_case(
    "\"a\\((1,2))b\\((3,4))\"", "null", "[\"a1b3\", \"a2b3\", \"a1b4\", \"a2b4\"]",
    0,
  )
}

///|
test "reference jq 1.7.1 098: frontend" {
  reference_case("\"\\(\"\\((1,2))\")\"", "null", "[\"1\", \"2\"]", 0)
}

///|
test "reference jq 1.7.1 099: frontend" {
  reference_case("\"\\(1 # ) ignored\n)\"", "null", "[\"1\"]", 0)
}

///|
test "reference jq 1.7.1 100: frontend" {
  reference_case("\"😀\\(. 1)\"", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 101: frontend" {
  reference_case("\"\\(\"(\")\"", "null", "[\"(\"]", 0)
}

///|
test "reference jq 1.7.1 102: frontend" {
  reference_case("\"\\(\"\\\"\")\"", "null", "[\"\\\"\"]", 0)
}

///|
test "reference jq 1.7.1 103: frontend" {
  reference_case("\"\\(null)\"", "null", "[\"null\"]", 0)
}

///|
test "reference jq 1.7.1 104: frontend" {
  reference_case("\"\\([1,2])\"", "null", "[\"[1,2]\"]", 0)
}

///|
test "reference jq 1.7.1 105: frontend" {
  reference_case("\"\\({a:1})\"", "null", "[\"{\\\"a\\\":1}\"]", 0)
}

///|
test "reference jq 1.7.1 106: stream" {
  reference_case("limit(3; repeat(.))", "null", "[null, null, null]", 0)
}

///|
test "reference jq 1.7.1 107: stream" {
  reference_case("limit(1; (1, ({} + 1)))", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 108: stream" {
  reference_case("1, ({} + 1), 2", "null", "[1]", 5)
}

///|
test "reference jq 1.7.1 109: stream" {
  reference_case("(1, ({}+1), 2)?", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 110: stream" {
  reference_case(
    "try (1, error({a:1}), 2) catch .", "null", "[1, {\"a\": 1}]", 0,
  )
}

///|
test "reference jq 1.7.1 111: stream" {
  reference_case("(try 1) | error(\"downstream\")", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 112: stream" {
  reference_case("false and error(\"unreachable\")", "null", "[false]", 0)
}

///|
test "reference jq 1.7.1 113: stream" {
  reference_case("true or error(\"unreachable\")", "null", "[true]", 0)
}

///|
test "reference jq 1.7.1 114: stream" {
  reference_case("(1,2)+(10,20)", "null", "[11, 12, 21, 22]", 0)
}

///|
test "reference jq 1.7.1 115: stream" {
  reference_case(
    "{a:(1,2),b:(3,4)}", "null", "[{\"a\": 1, \"b\": 3}, {\"a\": 1, \"b\": 4}, {\"a\": 2, \"b\": 3}, {\"a\": 2, \"b\": 4}]",
    0,
  )
}

///|
test "reference jq 1.7.1 116: stream" {
  reference_case("[empty]", "null", "[[]]", 0)
}

///|
test "reference jq 1.7.1 117: stream" {
  reference_case("null", "null", "[null]", 0)
}

///|
test "reference jq 1.7.1 118: stream" {
  reference_case("empty", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 119: stream" {
  reference_case("first(1,error(\"stop\"))", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 120: stream" {
  reference_case("last(empty)", "null", "[null]", 0)
}

///|
test "reference jq 1.7.1 121: stream" {
  reference_case("reduce (1,2) as $x (0; .+$x, .+10)", "null", "[20]", 0)
}

///|
test "reference jq 1.7.1 122: stream" {
  reference_case(
    "foreach (1,2) as $x (0; .+$x, .+10)", "null", "[1, 10, 12, 20]", 0,
  )
}

///|
test "reference jq 1.7.1 123: stream" {
  reference_case("def twice(f): f,f; twice(.+1)", "null", "[1, 1]", 0)
}

///|
test "reference jq 1.7.1 124: stream" {
  reference_case("def apply(f): 10|f; apply(.+1)", "null", "[11]", 0)
}

///|
test "reference jq 1.7.1 125: stream" {
  reference_case("def f($x): $x,$x; f((1,2))", "null", "[1, 1, 2, 2]", 0)
}

///|
test "reference jq 1.7.1 126: stream" {
  reference_case("1 as $x | def f: $x; 2 as $x | f", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 127: stream" {
  reference_case("def f: 1; def g: f; def f: 2; g", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 128: stream" {
  reference_case("range(0;3)", "null", "[0, 1, 2]", 0)
}

///|
test "reference jq 1.7.1 129: stream" {
  reference_case("reduce range(0;3) as $x (0; .+$x)", "null", "[3]", 0)
}

///|
test "reference jq 1.7.1 130: stream" {
  reference_case("limit(3; recurse(.+1))", "null", "[null, 1, 2]", 0)
}

///|
test "reference jq 1.7.1 131: stream" {
  reference_case("path(first(.[],error(\"stop\")))", "[1, 2]", "[[0]]", 0)
}

///|
test "reference jq 1.7.1 132: stream" {
  reference_case("path((.[],error(\"stop\"))?)", "[1, 2]", "[[0], [1]]", 0)
}

///|
test "reference jq 1.7.1 133: stream" {
  reference_case(".[] |= (.+1,error(\"stop\"))", "[1, 2]", "[[2, 3]]", 0)
}

///|
test "reference jq 1.7.1 134: stream" {
  reference_case(".[0] |= empty", "[1, 2]", "[[2]]", 0)
}

///|
test "reference jq 1.7.1 135: stream" {
  reference_case("path(null // .a)", "[1, 2]", "[]", 5)
}

///|
test "reference jq 1.7.1 136: stream" {
  reference_case("path(null | (.a | empty))", "[1, 2]", "[]", 5)
}

///|
test "reference jq 1.7.1 137: stream" {
  reference_case("path(last(.[]))", "[1, 2]", "[]", 5)
}

///|
test "reference jq 1.7.1 138: stream" {
  reference_case("[1,2] | map(.,.+10)", "null", "[[1, 11, 2, 12]]", 0)
}

///|
test "reference jq 1.7.1 139: stream" {
  reference_case("[1,2] | map_values(empty)", "null", "[[]]", 0)
}

///|
test "reference jq 1.7.1 140: stream" {
  reference_case("[1,2,3]| any(.[]; .>1)", "null", "[true]", 0)
}

///|
test "reference jq 1.7.1 141: stream" {
  reference_case("[1,2,3]| all(.[]; .>0)", "null", "[true]", 0)
}

///|
test "reference jq 1.7.1 142: extended" {
  reference_case("limit(0; error(\"unused\"))", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 143: extended" {
  reference_case("limit(-1; (1,2,3))", "null", "[1, 2, 3]", 0)
}

///|
test "reference jq 1.7.1 144: extended" {
  reference_case("limit((0,1,2); repeat(.))", "3", "[3, 3, 3]", 0)
}

///|
test "reference jq 1.7.1 145: extended" {
  reference_case("limit(3; repeat(empty,1))", "null", "[1, 1, 1]", 0)
}

///|
test "reference jq 1.7.1 146: extended" {
  reference_case("first(error({code:7}),1)", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 147: extended" {
  reference_case("[first(empty)]", "null", "[[]]", 0)
}

///|
test "reference jq 1.7.1 148: extended" {
  reference_case(
    "(try (1,error(\"inside\")) catch 2) | (., error(\"outside\"))", "null", "[1]",
    5,
  )
}

///|
test "reference jq 1.7.1 149: extended" {
  reference_case(
    "try ((1,2) | (.,error(\"inside\"))) catch {caught:.}", "null", "[1, {\"caught\": \"inside\"}]",
    0,
  )
}

///|
test "reference jq 1.7.1 150: extended" {
  reference_case(
    "[false, true] | .[] and (empty,true)", "null", "[false, true]", 0,
  )
}

///|
test "reference jq 1.7.1 151: extended" {
  reference_case(
    "(false,true) or (false,true)", "null", "[false, true, true]", 0,
  )
}

///|
test "reference jq 1.7.1 152: extended" {
  reference_case(
    "def unused(f): 1; unused(error(\"unused\"))", "null", "[1]", 0,
  )
}

///|
test "reference jq 1.7.1 153: extended" {
  reference_case("def f(x): x,x; 3 | f(.+1)", "null", "[4, 4]", 0)
}

///|
test "reference jq 1.7.1 154: extended" {
  reference_case(
    "def f($x;$y): [$x,$y]; f((1,2); (3,4))", "null", "[[1, 3], [1, 4], [2, 3], [2, 4]]",
    0,
  )
}

///|
test "reference jq 1.7.1 155: extended" {
  reference_case("def f(a): a|a; 2|f(.+1)", "null", "[4]", 0)
}

///|
test "reference jq 1.7.1 156: extended" {
  reference_case("def f: 1; def f(x): x; f, f(2)", "null", "[1, 2]", 0)
}

///|
test "reference jq 1.7.1 157: extended" {
  reference_case("10 as $x | def f: $x; 20 as $x | f", "null", "[10]", 0)
}

///|
test "reference jq 1.7.1 158: extended" {
  reference_case(
    "1 as $x | (def f: $x; f), (2 as $x | $x)", "null", "[1, 2]", 0,
  )
}

///|
test "reference jq 1.7.1 159: extended" {
  reference_case("def f: $x; 10 as $x | f", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 160: extended" {
  reference_case("def f(x): $x; f(1)", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 161: extended" {
  reference_case("def f: 1; f(2)", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 162: extended" {
  reference_case(".a[.b]", "{\"a\": {\"x\": 1}, \"b\": \"x\"}", "[1]", 0)
}

///|
test "reference jq 1.7.1 163: extended" {
  reference_case(
    "path(.a[.b])", "{\"a\": {\"x\": 1}, \"b\": \"x\"}", "[[\"a\", \"x\"]]", 0,
  )
}

///|
test "reference jq 1.7.1 164: extended" {
  reference_case(
    ".a[.b] |= .+1", "{\"a\": {\"x\": 1}, \"b\": \"x\"}", "[{\"a\": {\"x\": 2}, \"b\": \"x\"}]",
    0,
  )
}

///|
test "reference jq 1.7.1 165: extended" {
  reference_case("({a:[1,2]},{a:[3,4]}).a[(0,1)]", "null", "[1, 3, 2, 4]", 0)
}

///|
test "reference jq 1.7.1 166: extended" {
  reference_case(
    "[path(.a | select((true,false,true)))]", "{\"a\": 1}", "[[[\"a\"], [\"a\"]]]",
    0,
  )
}

///|
test "reference jq 1.7.1 167: extended" {
  reference_case("path(null // .a)", "{}", "[[\"a\"]]", 0)
}

///|
test "reference jq 1.7.1 168: extended" {
  reference_case("path((null|.a)?)", "{}", "[]", 0)
}

///|
test "reference jq 1.7.1 169: extended" {
  reference_case(
    "path(try (.[],error(\"x\")) catch .a)", "[1, 2]", "[[0], [1]]", 5,
  )
}

///|
test "reference jq 1.7.1 170: extended" {
  reference_case(
    "path((.a as $x | .b))", "{\"a\": 1, \"b\": 2}", "[[\"b\"]]", 0,
  )
}

///|
test "reference jq 1.7.1 171: extended" {
  reference_case(
    "(.a,.b) = (1,2)", "{\"a\": 0, \"b\": 0}", "[{\"a\": 1, \"b\": 1}, {\"a\": 2, \"b\": 2}]",
    0,
  )
}

///|
test "reference jq 1.7.1 172: extended" {
  reference_case(".[] += (1,2)", "[1, 2]", "[[2, 3], [3, 4]]", 0)
}

///|
test "reference jq 1.7.1 173: extended" {
  reference_case(
    ".[] |= (empty, .+1, error(\"unused\"))", "[1, 2]", "[[2, 3]]", 0,
  )
}

///|
test "reference jq 1.7.1 174: extended" {
  reference_case(
    "reduce (1,2) as $x (0; if $x==1 then empty else .+10 end)", "null", "[10]",
    0,
  )
}

///|
test "reference jq 1.7.1 175: extended" {
  reference_case(
    "foreach (1,2) as $x (0; if $x==1 then empty else .+10 end)", "null", "[10]",
    0,
  )
}

///|
test "reference jq 1.7.1 176: extended" {
  reference_case("foreach (1,2) as $x (0; .+$x; empty)", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 177: extended" {
  reference_case(
    "limit(2; foreach range(0;100) as $x (0; .+$x))", "null", "[0, 1]", 0,
  )
}

///|
test "reference jq 1.7.1 178: extended" {
  reference_case(
    "first(foreach (1,error(\"unused\")) as $x (0; .+$x))", "null", "[1]", 0,
  )
}

///|
test "reference jq 1.7.1 179: extended" {
  reference_case("reduce (1,2) as $x ((0,10); .+$x)", "null", "[3, 13]", 0)
}

///|
test "reference jq 1.7.1 180: extended" {
  reference_case("recurse(.+1; .<3)", "3", "[3]", 0)
}

///|
test "reference jq 1.7.1 181: extended" {
  reference_case("recurse(.+1; .<3)", "0", "[0, 1, 2]", 0)
}

///|
test "reference jq 1.7.1 182: extended" {
  reference_case(
    "limit(4; recurse(.[]?))", "{\"a\": [1, 2]}", "[{\"a\": [1, 2]}, [1, 2], 1, 2]",
    0,
  )
}

///|
test "reference jq 1.7.1 183: extended" {
  reference_case("[paths(ascii_downcase == \"x\")]", "{\"k\": \"X\"}", "[]", 5)
}

///|
test "reference jq 1.7.1 184: extended" {
  reference_case("first(combinations)", "[[1, 2], [3, 4]]", "[[1, 3]]", 0)
}

///|
test "reference jq 1.7.1 185: extended" {
  reference_case("combinations", "[]", "[[]]", 0)
}

///|
test "reference jq 1.7.1 186: extended" {
  reference_case("walk(empty)", "{\"a\": [1, 2]}", "[]", 0)
}

///|
test "reference jq 1.7.1 187: extended" {
  reference_case("\"😀\"|.[0:1]", "null", "[\"😀\"]", 0)
}

///|
test "reference jq 1.7.1 188: extended" {
  reference_case(
    "path(.[1:3])", "[1, 2, 3, 4]", "[[{\"start\": 1, \"end\": 3}]]", 0,
  )
}

///|
test "reference jq 1.7.1 189: extended" {
  reference_case(".[1:3] |= reverse", "[1, 2, 3, 4]", "[[1, 3, 2, 4]]", 0)
}

///|
test "reference jq 1.7.1 190: extended" {
  reference_case(".[1:3] = [8]", "[1, 2, 3, 4]", "[[1, 8, 4]]", 0)
}

///|
test "reference jq 1.7.1 191: extended" {
  reference_case(".[1:3] |= empty", "[1, 2, 3, 4]", "[[1, 4]]", 0)
}

///|
test "reference jq 1.7.1 192: extended" {
  reference_case("\"\\((empty,1))\\((2,3))\"", "null", "[\"12\", \"13\"]", 0)
}

///|
test "reference jq 1.7.1 193: extended" {
  reference_case(
    "\"\\((\"😀\",[1,2],{end:true}))\"", "null", "[\"😀\", \"[1,2]\", \"{\\\"end\\\":true}\"]",
    0,
  )
}

///|
test "reference jq 1.7.1 194: extended" {
  reference_case(
    "\"\\((\"\\((1,2))\", \"x\"))\"", "null", "[\"1\", \"2\", \"x\"]", 0,
  )
}

///|
test "reference jq 1.7.1 195: extended" {
  reference_case(
    "\"\\(1 # a quote \" and ) are comments\n + 2)\"", "null", "[\"3\"]", 0,
  )
}

///|
test "reference jq 1.7.1 196: extended" {
  reference_case("\"\\(1 2)\"", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 197: extended" {
  reference_case(".and.line", "{\"and\": {\"line\": 7}}", "[7]", 0)
}

///|
test "reference jq 1.7.1 198: extended" {
  reference_case(". and .line", "{\"line\": 0}", "[true]", 0)
}

///|
test "reference jq 1.7.1 199: extended" {
  reference_case(
    "split((\",\",\";\"))", "\"a,b;c\"", "[[\"a\", \"b;c\"], [\"a,b\", \"c\"]]",
    0,
  )
}

///|
test "reference jq 1.7.1 200: extended" {
  reference_case("has((\"a\",\"b\"))", "{\"a\": 1}", "[true, false]", 0)
}

///|
test "reference jq 1.7.1 201: extended" {
  reference_case(
    "range(.a; .b; .c)", "{\"a\": 1, \"b\": 5, \"c\": 2}", "[1, 3]", 0,
  )
}

///|
test "reference jq 1.7.1 202: extended" {
  reference_case("\"\\(error({reason:\"bad\"}))\"", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 203: binding" {
  reference_case("@", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 204: binding" {
  reference_case("$", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 205: binding" {
  reference_case("$1", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 206: binding" {
  reference_case("def not: 7; not", "null", "[7]", 0)
}

///|
test "reference jq 1.7.1 207: binding" {
  reference_case("not(1)", "null", "[]", 3)
}

///|
test "reference jq 1.7.1 208: alternative assignment" {
  reference_case(".a //= (1,2)", "{}", "[{\"a\": 1}, {\"a\": 2}]", 0)
}

///|
test "reference jq 1.7.1 209: alternative assignment" {
  reference_case(".a //= empty", "{}", "[]", 0)
}

///|
test "reference jq 1.7.1 210: alternative assignment" {
  reference_case(".a //= (1,error(\"rhs\"),2)", "{}", "[{\"a\": 1}]", 5)
}

///|
test "reference jq 1.7.1 211: alternative assignment" {
  reference_case(
    "(.a,.b) //= (1,2)", "{}", "[{\"a\": 1, \"b\": 1}, {\"a\": 2, \"b\": 2}]", 0,
  )
}

///|
test "reference jq 1.7.1 212: alternative assignment" {
  reference_case(".a //= (.k // 7)", "{}", "[{\"a\": 7}]", 0)
}

///|
test "reference jq 1.7.1 213: alternative assignment" {
  reference_case("first(.a //= (1,error(\"unused\")))", "{}", "[{\"a\": 1}]", 0)
}

///|
test "reference jq 1.7.1 214: alternative assignment" {
  reference_case(
    "limit(2; .a //= (1,2,error(\"unused\")))", "{}", "[{\"a\": 1}, {\"a\": 2}]",
    0,
  )
}

///|
test "reference jq 1.7.1 215: alternative assignment" {
  reference_case(
    ".a //= (false,null,0)", "{}", "[{\"a\": false}, {\"a\": null}, {\"a\": 0}]",
    0,
  )
}

///|
test "reference jq 1.7.1 216: alternative assignment" {
  reference_case(".a += (1,2)", "{}", "[{\"a\": 1}, {\"a\": 2}]", 0)
}

///|
test "reference jq 1.7.1 217: alternative assignment" {
  reference_case("(.a,.a) //= (1,2)", "{}", "[{\"a\": 1}, {\"a\": 2}]", 0)
}

///|
test "reference jq 1.7.1 218: alternative assignment" {
  reference_case(
    ".a //= (1,2)", "{\"a\": 1, \"b\": false, \"k\": 4}", "[{\"a\": 1, \"b\": false, \"k\": 4}, {\"a\": 1, \"b\": false, \"k\": 4}]",
    0,
  )
}

///|
test "reference jq 1.7.1 219: alternative assignment" {
  reference_case(".a //= empty", "{\"a\": 1, \"b\": false, \"k\": 4}", "[]", 0)
}

///|
test "reference jq 1.7.1 220: alternative assignment" {
  reference_case(".a //= (1/0)", "{\"a\": 1, \"b\": false, \"k\": 4}", "[]", 5)
}

///|
test "reference jq 1.7.1 221: alternative assignment" {
  reference_case(
    ".a //= (2,error(\"rhs\"))", "{\"a\": 1, \"b\": false, \"k\": 4}", "[{\"a\": 1, \"b\": false, \"k\": 4}]",
    5,
  )
}

///|
test "reference jq 1.7.1 222: alternative assignment" {
  reference_case(
    "(.a,.b) //= (.k,.k+1)", "{\"a\": 1, \"b\": false, \"k\": 4}", "[{\"a\": 1, \"b\": 4, \"k\": 4}, {\"a\": 1, \"b\": 5, \"k\": 4}]",
    0,
  )
}

///|
test "reference jq 1.7.1 223: alternative assignment" {
  reference_case(
    "(.a,.b) += (.k,.k+1)", "{\"a\": 1, \"b\": false, \"k\": 4}", "[]", 5,
  )
}

///|
test "reference jq 1.7.1 224: alternative assignment" {
  reference_case(
    ".a //= (.a+2)", "{\"a\": 1, \"b\": false, \"k\": 4}", "[{\"a\": 1, \"b\": false, \"k\": 4}]",
    0,
  )
}

///|
test "reference jq 1.7.1 225: containment" {
  reference_case("contains({a:2})", "{\"a\": null}", "[false]", 0)
}

///|
test "reference jq 1.7.1 226: containment" {
  reference_case("inside({a:2})", "{\"a\": null}", "[false]", 0)
}

///|
test "reference jq 1.7.1 227: containment" {
  reference_case("inside([null,1])", "[1]", "[true]", 0)
}

///|
test "reference jq 1.7.1 228: containment" {
  reference_case("contains([null,1])", "[1]", "[false]", 0)
}

///|
test "reference jq 1.7.1 229: containment" {
  reference_case(
    "contains([{a:2}])", "[{\"a\": null}, {\"a\": 2}, \"x\", null]", "[true]", 0,
  )
}

///|
test "reference jq 1.7.1 230: containment" {
  reference_case(
    "contains([{a:3}])", "[{\"a\": null}, {\"a\": 2}, \"x\", null]", "[false]", 0,
  )
}

///|
test "reference jq 1.7.1 231: containment" {
  reference_case(
    "contains([\"x\",null,{a:2}])", "[{\"a\": null}, {\"a\": 2}, \"x\", null]", "[true]",
    0,
  )
}

///|
test "reference jq 1.7.1 232: containment" {
  reference_case(
    "contains({a:[{b:\"a\"},true]})", "{\"a\": [null, {\"b\": \"abc\"}, false, true]}",
    "[true]", 0,
  )
}

///|
test "reference jq 1.7.1 233: containment" {
  reference_case(
    "contains({a:[{b:1}]})", "{\"a\": [null, {\"b\": \"abc\"}, false, true]}", "[false]",
    0,
  )
}

///|
test "reference jq 1.7.1 234: containment kinds" {
  reference_case("contains(false)", "true", "[]", 5)
}

///|
test "reference jq 1.7.1 235: containment kinds" {
  reference_case("inside(false)", "true", "[]", 5)
}

///|
test "reference jq 1.7.1 236: containment kinds" {
  reference_case("contains(true)", "false", "[]", 5)
}

///|
test "reference jq 1.7.1 237: containment kinds" {
  reference_case("inside(true)", "false", "[]", 5)
}

///|
test "reference jq 1.7.1 238: containment kinds" {
  reference_case("contains(true)", "true", "[true]", 0)
}

///|
test "reference jq 1.7.1 239: containment kinds" {
  reference_case("inside(true)", "true", "[true]", 0)
}

///|
test "reference jq 1.7.1 240: containment kinds" {
  reference_case("contains(false)", "false", "[true]", 0)
}

///|
test "reference jq 1.7.1 241: containment kinds" {
  reference_case("inside(false)", "false", "[true]", 0)
}

///|
test "reference jq 1.7.1 242: containment kinds" {
  reference_case("contains(0)", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 243: containment kinds" {
  reference_case("inside(0)", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 244: containment kinds" {
  reference_case("contains({})", "[]", "[]", 5)
}

///|
test "reference jq 1.7.1 245: containment kinds" {
  reference_case("inside({})", "[]", "[]", 5)
}

///|
test "reference jq 1.7.1 246: containment kinds" {
  reference_case("contains([true])", "[false, true, null]", "[true]", 0)
}

///|
test "reference jq 1.7.1 247: containment kinds" {
  reference_case("contains([false])", "[false, true, null]", "[true]", 0)
}

///|
test "reference jq 1.7.1 248: containment kinds" {
  reference_case("contains([0])", "[false, true, null]", "[false]", 0)
}

///|
test "reference jq 1.7.1 249: range evaluation order" {
  reference_case(
    "[range((0,1);(2,3))]", "null", "[[0, 1, 0, 1, 2, 1, 1, 2]]", 0,
  )
}

///|
test "reference jq 1.7.1 250: range evaluation order" {
  reference_case(
    "[range((0,1);(3,4);(1,2))]", "null", "[[0, 1, 2, 0, 2, 0, 1, 2, 3, 0, 2, 1, 2, 1, 1, 2, 3, 1, 3]]",
    0,
  )
}

///|
test "reference jq 1.7.1 251: range evaluation order" {
  reference_case("range(1/0;empty)", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 252: range evaluation order" {
  reference_case("range(empty;1/0)", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 253: range evaluation order" {
  reference_case("range(1/0;empty;1)", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 254: range evaluation order" {
  reference_case("range(0;1/0;empty)", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 255: range evaluation order" {
  reference_case("range(empty;1/0;1)", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 256: range evaluation order" {
  reference_case("range(0;empty;1/0)", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 257: range evaluation order" {
  reference_case("range((0,error(\"start\"));2)", "null", "[0, 1]", 5)
}

///|
test "reference jq 1.7.1 258: range evaluation order" {
  reference_case("range(0;(2,error(\"end\")))", "null", "[0, 1]", 5)
}

///|
test "reference jq 1.7.1 259: range evaluation order" {
  reference_case("range(0;3;(1,error(\"step\")))", "null", "[0, 1, 2]", 5)
}

///|
test "reference jq 1.7.1 260: range evaluation order" {
  reference_case("range((0,error(\"start\"));empty)", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 261: range evaluation order" {
  reference_case("first(range((0,error(\"unused\"));3))", "null", "[0]", 0)
}

///|
test "reference jq 1.7.1 262: range evaluation order" {
  reference_case("limit(2;range(0;1000000000))", "null", "[0, 1]", 0)
}

///|
test "reference jq 1.7.1 263: range evaluation order" {
  reference_case(
    "[range((4,3);(0,1);(-1,-2))]", "null", "[[4, 3, 2, 1, 4, 2, 4, 3, 2, 4, 2, 3, 2, 1, 3, 1, 3, 2, 3]]",
    0,
  )
}

///|
test "reference jq 1.7.1 264: range evaluation order" {
  reference_case("setpath((error(\"left\"),[]);empty)", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 265: range evaluation order" {
  reference_case("pow(1/0;empty)", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 266: interpolated subscript" {
  reference_case(
    ".a.\"\\(.k)\"", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[1]", 0,
  )
}

///|
test "reference jq 1.7.1 267: interpolated subscript" {
  reference_case(
    "path(.a.\"\\(.k)\")", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[[\"a\", \"x\"]]", 0,
  )
}

///|
test "reference jq 1.7.1 268: interpolated subscript" {
  reference_case(
    ".a.\"\\(.k)\" = (8,9)", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[{\"a\": {\"x\": 8, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}, {\"a\": {\"x\": 9, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}]",
    0,
  )
}

///|
test "reference jq 1.7.1 269: interpolated subscript" {
  reference_case(
    ".a.\"\\(.k)\" |= .+1", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[{\"a\": {\"x\": 2, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}]", 0,
  )
}

///|
test "reference jq 1.7.1 270: interpolated subscript" {
  reference_case(
    ".a.\"\\(.k)\" //= (8,9)", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}, {\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}]",
    0,
  )
}

///|
test "reference jq 1.7.1 271: interpolated subscript" {
  reference_case(
    "[.a.\"\\(.keys[])\" ]", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[[1, 2]]", 0,
  )
}

///|
test "reference jq 1.7.1 272: interpolated subscript" {
  reference_case(
    "[path(.a.\"\\(.keys[])\")]", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[[[\"a\", \"x\"], [\"a\", \"y\"]]]", 0,
  )
}

///|
test "reference jq 1.7.1 273: interpolated subscript" {
  reference_case(
    ".a.\"\\(.keys[])\" = 8", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[{\"a\": {\"x\": 8, \"y\": 8}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}]", 0,
  )
}

///|
test "reference jq 1.7.1 274: interpolated subscript" {
  reference_case(
    ".a.\"\\(.keys[])\" |= .+1", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[{\"a\": {\"x\": 2, \"y\": 3}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}]", 0,
  )
}

///|
test "reference jq 1.7.1 275: interpolated subscript" {
  reference_case(
    ".a.\"\\((.k,error(\"key\")))\"", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[1]", 5,
  )
}

///|
test "reference jq 1.7.1 276: interpolated subscript" {
  reference_case(
    "first(.a.\"\\((.k,error(\"unused\")))\")", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[1]", 0,
  )
}

///|
test "reference jq 1.7.1 277: interpolated subscript" {
  reference_case(
    ".a.\"\\(empty)\"", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[]", 0,
  )
}

///|
test "reference jq 1.7.1 278: interpolated subscript" {
  reference_case(
    ".a.\"\\(.k)\" |= empty", "{\"a\": {\"x\": 1, \"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}",
    "[{\"a\": {\"y\": 2}, \"k\": \"x\", \"keys\": [\"x\", \"y\"]}]", 0,
  )
}

///|
test "reference jq 1.7.1 279: lexical callables" {
  reference_case("def f(g): def g: 42; g; f(1)", "null", "[42]", 0)
}

///|
test "reference jq 1.7.1 280: lexical callables" {
  reference_case("def g: 9; def f(g): g; f(1)", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 281: lexical callables" {
  reference_case(
    "def g(x): x+10; def f(g): g, g(2); f(1)", "null", "[1, 12]", 0,
  )
}

///|
test "reference jq 1.7.1 282: lexical callables" {
  reference_case("def f(g): def g(x): x+10; g,g(2); f(1)", "null", "[1, 12]", 0)
}

///|
test "reference jq 1.7.1 283: lexical callables" {
  reference_case(
    "def f(g): def saved: g; def g: 42; saved,g; f(1)", "null", "[1, 42]", 0,
  )
}

///|
test "reference jq 1.7.1 284: lexical callables" {
  reference_case(
    "def g: 10; def saved: g; def g: 20; saved,g", "null", "[10, 20]", 0,
  )
}

///|
test "reference jq 1.7.1 285: lexical callables" {
  reference_case(
    "def f(g): def g: if .>0 then .-1|g else 42 end; 2|g; f(1)", "null", "[42]",
    0,
  )
}

///|
test "reference jq 1.7.1 286: lexical callables" {
  reference_case(
    "def f(g): def g(x): if x>0 then g(x-1) else g end; g(2); f(7)", "null", "[7]",
    0,
  )
}

///|
test "reference jq 1.7.1 287: lexical callables" {
  reference_case("def f(g): (def g: 42; g),g; f(1)", "null", "[42, 1]", 0)
}

///|
test "reference jq 1.7.1 288: lexical callables" {
  reference_case("def f(g): def h: g; def g: 42; h; f(1)", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 289: lexical callables" {
  reference_case("def f(g): def h(g): g; h(8),g; f(1)", "null", "[8, 1]", 0)
}

///|
test "reference jq 1.7.1 290: value filter parameters" {
  reference_case("def f($x): x; f(1)", "null", "[1]", 0)
}

///|
test "reference jq 1.7.1 291: value filter parameters" {
  reference_case(
    "def f($x): [$x,x]; f((1,2))", "null", "[[1, 1, 2], [2, 1, 2]]", 0,
  )
}

///|
test "reference jq 1.7.1 292: value filter parameters" {
  reference_case("def f($x): 10 | x; 1 | f(.+1)", "null", "[11]", 0)
}

///|
test "reference jq 1.7.1 293: value filter parameters" {
  reference_case(
    "def f($x): [$x,(10|x),$x]; 1 | f(.+1)", "null", "[[2, 11, 2]]", 0,
  )
}

///|
test "reference jq 1.7.1 294: value filter parameters" {
  reference_case(
    "def f($x;$y): [$x,$y,x,y]; f((1,2);(3,4))", "null", "[[1, 3, 1, 2, 3, 4], [1, 4, 1, 2, 3, 4], [2, 3, 1, 2, 3, 4], [2, 4, 1, 2, 3, 4]]",
    0,
  )
}

///|
test "reference jq 1.7.1 295: value filter parameters" {
  reference_case(
    "def f($x;$y): [$x,$y]; f(error(\"first\");empty)", "null", "[]", 5,
  )
}

///|
test "reference jq 1.7.1 296: value filter parameters" {
  reference_case(
    "def f($x;$y): [$x,$y]; f(empty;error(\"second\"))", "null", "[]", 0,
  )
}

///|
test "reference jq 1.7.1 297: value filter parameters" {
  reference_case(
    "def f($x;$y): [$x,$y]; f((1,error(\"first\"));(2,error(\"second\")))", "null",
    "[[1, 2]]", 5,
  )
}

///|
test "reference jq 1.7.1 298: value filter parameters" {
  reference_case("def f($x): def x: 42; [$x,x]; f(1)", "null", "[[1, 42]]", 0)
}

///|
test "reference jq 1.7.1 299: value filter parameters" {
  reference_case("def x: 9; def f($x): [$x,x]; f(1)", "null", "[[1, 1]]", 0)
}

///|
test "reference jq 1.7.1 300: value filter parameters" {
  reference_case("def f($x): def h: x; 10 | h; 1|f(.+1)", "null", "[11]", 0)
}

///|
test "reference jq 1.7.1 301: value filter parameters" {
  reference_case("def f($x): 2 as $x | [$x,x]; f(1)", "null", "[[2, 1]]", 0)
}

///|
test "reference jq 1.7.1 302: value filter parameters" {
  reference_case("def f($x): x,x; f((1,error(\"rerun\")))", "null", "[1]", 5)
}

///|
test "reference jq 1.7.1 303: value filter parameters" {
  reference_case(
    "first(def f($x): [$x,x]; f((1,error(\"unused\"))))", "null", "[]", 5,
  )
}

///|
test "reference jq 1.7.1 304: value filter parameters" {
  reference_case("def f($x): 42; f(empty)", "null", "[]", 0)
}

///|
test "reference jq 1.7.1 305: slice writes" {
  reference_case(".[0:0] = [1]", "null", "[[1]]", 0)
}

///|
test "reference jq 1.7.1 306: slice writes" {
  reference_case(".[1:3] = [1,2]", "null", "[[1, 2]]", 0)
}

///|
test "reference jq 1.7.1 307: slice writes" {
  reference_case(".[0:0][0] = 1", "null", "[[1]]", 0)
}

///|
test "reference jq 1.7.1 308: slice writes" {
  reference_case(".[0:0][0:0] = [1]", "null", "[[1]]", 0)
}

///|
test "reference jq 1.7.1 309: slice writes" {
  reference_case(".[0:0] |= .+[1]", "null", "[[1]]", 0)
}

///|
test "reference jq 1.7.1 310: slice writes" {
  reference_case(".[0:0] = 1", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 311: slice writes" {
  reference_case(".[0:0] = null", "null", "[]", 5)
}

///|
test "reference jq 1.7.1 312: slice writes" {
  reference_case(".[0:0][0] |= .+1", "null", "[[1]]", 0)
}

///|
test "reference jq 1.7.1 313: slice writes" {
  reference_case(".a[0:0] = [1]", "{}", "[{\"a\": [1]}]", 0)
}

///|
test "reference jq 1.7.1 314: slice writes" {
  reference_case(".a[0:0][0:0] = [1]", "{}", "[{\"a\": [1]}]", 0)
}

///|
test "reference jq 1.7.1 315: slice writes" {
  reference_case(".a[0:0][0].b = 1", "{}", "[{\"a\": [{\"b\": 1}]}]", 0)
}

///|
test "reference jq 1.7.1 316: slice writes" {
  reference_case(
    ".a[0:0] //= ([1],[2])", "{}", "[{\"a\": [1]}, {\"a\": [2]}]", 0,
  )
}

///|
test "reference jq 1.7.1 317: slice writes" {
  reference_case(".a[0:0] = {}", "{}", "[]", 5)
}

///|
test "reference jq 1.7.1 318: slice writes" {
  reference_case(
    ".[1:4][1:2] = [8,9]", "[0, 1, 2, 3, 4]", "[[0, 1, 8, 9, 3, 4]]", 0,
  )
}

///|
test "reference jq 1.7.1 319: slice writes" {
  reference_case(
    ".[1:4][0] |= .+10", "[0, 1, 2, 3, 4]", "[[0, 11, 2, 3, 4]]", 0,
  )
}

///|
test "reference jq 1.7.1 320: slice writes" {
  reference_case(
    ".[1:4][0:1][0] = 8", "[0, 1, 2, 3, 4]", "[[0, 8, 2, 3, 4]]", 0,
  )
}

///|
test "reference jq 1.7.1 321: slice writes" {
  reference_case(
    ".[1:4] = ([],[8,9])", "[0, 1, 2, 3, 4]", "[[0, 4], [0, 8, 9, 4]]", 0,
  )
}

///|
test "reference jq 1.7.1 322: slice deletes" {
  reference_case(".[1:3][0] |= empty", "[1, 2, 3, 4]", "[[1, 3, 4]]", 0)
}

///|
test "reference jq 1.7.1 323: slice deletes" {
  reference_case(".[1:3][] |= empty", "[1, 2, 3, 4]", "[[1, 4]]", 0)
}

///|
test "reference jq 1.7.1 324: slice deletes" {
  reference_case(".[1:3][-1] |= empty", "[1, 2, 3, 4]", "[[1, 2, 4]]", 0)
}

///|
test "reference jq 1.7.1 325: slice deletes" {
  reference_case(".[1:4][1:2][] |= empty", "[1, 2, 3, 4]", "[[1, 2, 4]]", 0)
}

///|
test "reference jq 1.7.1 326: slice deletes" {
  reference_case(".[1:3][0:1] |= empty", "[1, 2, 3, 4]", "[[1, 3, 4]]", 0)
}

///|
test "reference jq 1.7.1 327: slice deletes" {
  reference_case(
    "(.[1:3][0],.[1:3][0]) |= empty", "[1, 2, 3, 4]", "[[1, 3, 4]]", 0,
  )
}

///|
test "reference jq 1.7.1 328: slice deletes" {
  reference_case("(.[1:3][0],.[2]) |= empty", "[1, 2, 3, 4]", "[[1, 3]]", 0)
}

///|
test "reference jq 1.7.1 329: slice deletes" {
  reference_case("(.[1:3],.[1:3][0]) |= empty", "[1, 2, 3, 4]", "[[1, 4]]", 0)
}

///|
test "reference jq 1.7.1 330: slice deletes" {
  reference_case(
    "(.[0:3][1],.[1:4][0]) |= empty", "[1, 2, 3, 4]", "[[1, 4]]", 0,
  )
}

///|
test "reference jq 1.7.1 331: slice deletes" {
  reference_case(
    "delpaths([[{start:1,end:3},0]])", "[1, 2, 3, 4]", "[[1, 3, 4]]", 0,
  )
}

///|
test "reference jq 1.7.1 332: slice deletes" {
  reference_case(
    "delpaths([[{start:1,end:3},0],[{start:1,end:3},1]])", "[1, 2, 3, 4]", "[[1, 4]]",
    0,
  )
}

///|
test "reference jq 1.7.1 333: slice deletes" {
  reference_case(
    "delpaths([[{start:1,end:4},{start:1,end:2},0]])", "[1, 2, 3, 4]", "[[1, 2, 4]]",
    0,
  )
}

///|
test "reference jq 1.7.1 334: slice deletes" {
  reference_case(
    "delpaths([[{start:1,end:3},0],[2]])", "[1, 2, 3, 4]", "[[1, 3]]", 0,
  )
}

///|
test "reference jq 1.7.1 335: slice deletes" {
  reference_case(
    "delpaths([[{start:1,end:3}],[{start:1,end:3},0]])", "[1, 2, 3, 4]", "[[1, 4]]",
    0,
  )
}

///|
test "reference jq 1.7.1 336: slice deletes" {
  reference_case(
    "delpaths([[{start:0,end:3},1],[{start:1,end:4},0]])", "[1, 2, 3, 4]", "[[1, 4]]",
    0,
  )
}

///|
test "reference jq 1.7.1 337: slice deletes" {
  reference_case(
    "delpaths([[-1],[3],[{start:1,end:3},0]])", "[1, 2, 3, 4]", "[[1, 3]]", 0,
  )
}

///|
test "reference jq 1.7.1 338: slice deletes" {
  reference_case(
    ".[0:2][].x |= empty", "[{\"x\": 1, \"y\": 2}, {\"x\": 3, \"y\": 4}, {\"x\": 5}]",
    "[[{\"y\": 2}, {\"y\": 4}, {\"x\": 5}]]", 0,
  )
}

///|
test "reference jq 1.7.1 339: slice deletes" {
  reference_case(
    ".[0:2][0].x |= empty", "[{\"x\": 1, \"y\": 2}, {\"x\": 3, \"y\": 4}, {\"x\": 5}]",
    "[[{\"y\": 2}, {\"x\": 3, \"y\": 4}, {\"x\": 5}]]", 0,
  )
}

///|
test "reference jq 1.7.1 340: slice deletes" {
  reference_case(
    "(.[0:2][0].x,.[1:3][0].y) |= empty", "[{\"x\": 1, \"y\": 2}, {\"x\": 3, \"y\": 4}, {\"x\": 5}]",
    "[[{\"y\": 2}, {\"x\": 3}, {\"x\": 5}]]", 0,
  )
}

///|
test "reference jq 1.7.1 341: slice deletes" {
  reference_case(
    ".[0:2][0][0:1][] |= empty", "[[1, 2], [3, 4], [5, 6]]", "[[[2], [3, 4], [5, 6]]]",
    0,
  )
}

///|
test "reference jq 1.7.1 342: slice deletes" {
  reference_case(
    ".[0:2][][0] |= empty", "[[1, 2], [3, 4], [5, 6]]", "[[[2], [4], [5, 6]]]", 0,
  )
}
