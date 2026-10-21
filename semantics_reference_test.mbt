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
