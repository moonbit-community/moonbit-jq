// Property-based tests for the jq engine.
//
// The properties below state jq's documented semantics as algebraic laws and
// compare the engine against small reference models written in this file.
// Every `check` uses a fixed seed so CI runs are deterministic.

// ---------------------------------------------------------------------------
// Random JSON generation
// ---------------------------------------------------------------------------

///|
/// A generated JSON value, wrapped so it can carry `Arbitrary`/`Shrink`.
struct JV {
  v : Json
} derive(Debug)

///|
fn rand_below(rs : @quickcheck.RandomState, n : Int) -> Int {
  rs.next_positive_int() % n
}

///|
/// Characters that stress escaping and code point handling: JSON escapes,
/// control characters, BMP characters on both sides of the surrogate range,
/// and astral characters (surrogate pairs in UTF-16).
let special_chars : Array[Char] = [
  '"', '\\', '/', '\n', '\t', '\r', '\u{08}', '\u{0C}', '\u{00}', '\u{1F}', '\u{7F}',
  'é', 'ß', '中', '\u{2028}', '\u{D7FF}', '\u{E000}', '\u{FEFF}', '\u{FFFF}',
  '😀', '𝄞', '\u{10FFFF}',
]

///|
fn gen_char(rs : @quickcheck.RandomState) -> Char {
  match rand_below(rs, 10) {
    0..=5 => ('a'.to_int() + rand_below(rs, 26)).unsafe_to_char()
    6 => (0x20 + rand_below(rs, 95)).unsafe_to_char()
    _ => special_chars[rand_below(rs, special_chars.length())]
  }
}

///|
fn gen_string(rs : @quickcheck.RandomState, max_len : Int) -> String {
  let len = rand_below(rs, max_len + 1)
  let sb = StringBuilder()
  for _ in 0..<len {
    sb.write_char(gen_char(rs))
  }
  sb.to_string()
}

///|
/// Small key pool so objects share keys (interesting for comparison, sort and
/// unique), including keys whose UTF-16 and code point orders disagree.
let key_pool : Array[String] = [
  "a", "b", "c", "aa", "ab", "B", "", "é", "😀", "\u{E000}", "key", "a\"b", "x y",
  "10",
]

///|
fn gen_key(rs : @quickcheck.RandomState, size : Int) -> String {
  if rand_below(rs, 4) == 0 {
    gen_string(rs, size / 2 + 1)
  } else {
    key_pool[rand_below(rs, key_pool.length())]
  }
}

///|
let special_numbers : Array[Double] = [
  0.0, -0.0, 1.0, -1.0, 0.1, 0.5, 2.5, 1.0e300, -1.0e300, 1.0e-300, 5.0e-324, 1.7976931348623157e308,
  9007199254740992.0, -9007199254740992.0, 123456789012.0, 1.0e21, 1.0e-7,
]

///|
fn gen_number(rs : @quickcheck.RandomState) -> Double {
  match rand_below(rs, 5) {
    0 | 1 => (rand_below(rs, 201) - 100).to_double()
    2 => (rs.next_int64() % 9007199254740992L).to_double()
    3 => (rs.next_double() - 0.5) * 2000.0
    _ => special_numbers[rand_below(rs, special_numbers.length())]
  }
}

///|
fn gen_json(rs : @quickcheck.RandomState, size : Int, depth : Int) -> Json {
  let container_weight = if depth <= 0 { 0 } else { 8 }
  match rand_below(rs, 10 + container_weight) {
    0 => Json::null()
    1 => Json::boolean(true)
    2 => Json::boolean(false)
    3..=5 => Json::number(gen_number(rs))
    6..=9 => Json::string(gen_string(rs, size / 2 + 1))
    10..=13 => {
      let len = rand_below(rs, (if size < 6 { size } else { 6 }) + 1)
      Json::array(Array::makei(len, _ => gen_json(rs, size * 2 / 3, depth - 1)))
    }
    _ => {
      let len = rand_below(rs, (if size < 5 { size } else { 5 }) + 1)
      let obj : Map[String, Json] = Map([])
      for _ in 0..<len {
        obj[gen_key(rs, size)] = gen_json(rs, size * 2 / 3, depth - 1)
      }
      Json::object(obj)
    }
  }
}

///|
fn depth_for(size : Int) -> Int {
  let d = (size + 4) / 5
  if d > 4 {
    4
  } else {
    d
  }
}

///|
impl @quickcheck.Arbitrary for JV with fn arbitrary(size, rs) {
  { v: gen_json(rs, size, depth_for(size)), }
}

///|
/// Shrink candidates: structurally smaller values only, so shrinking ends.
fn shrink_json(v : Json) -> Array[Json] {
  match v {
    Null => []
    True | False => [Json::null()]
    Number(n, ..) => {
      let out = [Json::null()]
      if n != 0.0 {
        out.push(Json::number(0.0))
        if n.trunc() != n && n.trunc().abs() < n.abs() {
          out.push(Json::number(n.trunc()))
        }
      }
      out
    }
    String(s) => {
      let cs = s.to_array()
      if cs.is_empty() {
        [Json::null()]
      } else {
        [
          Json::string(""),
          Json::string(String::from_array(cs[1:])),
          Json::string(String::from_array(cs[:cs.length() / 2])),
        ]
      }
    }
    Array(a) => {
      let out : Array[Json] = []
      for x in a {
        out.push(x)
      }
      for i in 0..<a.length() {
        let smaller = a.copy()
        smaller.remove(i) |> ignore
        out.push(Json::array(smaller))
      }
      for i in 0..<a.length() {
        for s in shrink_json(a[i]) {
          let c = a.copy()
          c[i] = s
          out.push(Json::array(c))
        }
      }
      out
    }
    Object(o) => {
      let out : Array[Json] = []
      for _, x in o {
        out.push(x)
      }
      for k, _ in o {
        let smaller = o.copy()
        smaller.remove(k)
        out.push(Json::object(smaller))
      }
      for k, x in o {
        for s in shrink_json(x) {
          let c = o.copy()
          c[k] = s
          out.push(Json::object(c))
        }
      }
      out
    }
  }
}

///|
impl @quickcheck.Shrink for JV with fn shrink(self) {
  shrink_json(self.v).iter().map(v => { v, })
}

///|
/// A pair of JSON values where the second is often derived from the first
/// (equal, a shrink of it, or sharing its type), so that comparison
/// properties see equal and near-equal values and not just type-rank ties.
struct JPair {
  a : Json
  b : Json
} derive(Debug)

///|
impl @quickcheck.Arbitrary for JPair with fn arbitrary(size, rs) {
  let d = depth_for(size)
  let a = gen_json(rs, size, d)
  let b = match rand_below(rs, 4) {
    0 => a
    1 => {
      let cands = shrink_json(a)
      if cands.is_empty() {
        a
      } else {
        cands[rand_below(rs, cands.length())]
      }
    }
    _ => gen_json(rs, size, d)
  }
  if rand_below(rs, 2) == 0 {
    { a, b, }
  } else {
    { a: b, b: a, }
  }
}

///|
impl @quickcheck.Shrink for JPair with fn shrink(self) {
  let out : Array[JPair] = []
  for a in shrink_json(self.a) {
    out.push({ a, b: self.b, })
  }
  for b in shrink_json(self.b) {
    out.push({ a: self.a, b, })
  }
  out.iter()
}

///|
/// A JSON value together with one of its paths (as produced by `paths`) and
/// a replacement value.
struct JPathCase {
  v : Json
  path : Json
  x : Json
} derive(Debug)

///|
impl @quickcheck.Arbitrary for JPathCase with fn arbitrary(size, rs) {
  // Prefer nested containers (a few attempts), so that paths are long.
  let mut v = gen_json(rs, size + 5, depth_for(size) + 1)
  for _ in 0..<4 {
    if depth_of(v) >= 2 {
      break
    }
    v = gen_json(rs, size + 5, depth_for(size) + 1)
  }
  if !(v is (Array(_) | Object(_))) {
    v = Json::array([v])
  }
  let all = ref_paths(v)
  // Half the time pick among the longest paths, so deep paths are common.
  let longest = all.fold(init=0, (m, p) => {
    if p.length() > m {
      p.length()
    } else {
      m
    }
  })
  let pool = if rand_below(rs, 2) == 0 {
    all.filter(p => p.length() == longest)
  } else {
    all
  }
  let path = if pool.is_empty() {
    Json::array([])
  } else {
    Json::array(pool[rand_below(rs, pool.length())])
  }
  { v, path, x: gen_json(rs, size / 2, 1), }
}

///|
impl @quickcheck.Shrink for JPathCase with fn shrink(self) {
  // Keep the path valid: only shrink the replacement value.
  shrink_json(self.x).iter().map(x => { v: self.v, path: self.path, x, })
}

///|
/// A fresh path (keys and small non-negative indices) to be created by
/// `setpath` on `null`.
struct FreshPath {
  path : Array[Json]
  x : Json
} derive(Debug)

///|
impl @quickcheck.Arbitrary for FreshPath with fn arbitrary(size, rs) {
  let len = rand_below(rs, 5)
  let path = Array::makei(len, _ => {
    if rand_below(rs, 2) == 0 {
      Json::string(gen_key(rs, size))
    } else {
      Json::number(rand_below(rs, 4).to_double())
    }
  })
  { path, x: gen_json(rs, size / 2, 1), }
}

///|
impl @quickcheck.Shrink for FreshPath with fn shrink(self) {
  let out : Array[FreshPath] = []
  for i in 0..<self.path.length() {
    let p = self.path.copy()
    p.remove(i) |> ignore
    out.push({ path: p, x: self.x, })
  }
  for x in shrink_json(self.x) {
    out.push({ path: self.path, x, })
  }
  out.iter()
}

// ---------------------------------------------------------------------------
// Reference models
// ---------------------------------------------------------------------------

///|
fn type_rank(v : Json) -> Int {
  match v {
    Null => 0
    False => 1
    True => 2
    Number(_) => 3
    String(_) => 4
    Array(_) => 5
    Object(_) => 6
  }
}

///|
/// jq orders strings by Unicode code point (byte-wise on UTF-8).
fn ref_cmp_str(a : String, b : String) -> Int {
  let ca = a.to_array()
  let cb = b.to_array()
  let n = if ca.length() < cb.length() { ca.length() } else { cb.length() }
  for i in 0..<n {
    let c = ca[i].compare(cb[i])
    if c != 0 {
      return c
    }
  }
  ca.length().compare(cb.length())
}

///|
fn ref_sorted_keys(o : Map[String, Json]) -> Array[String] {
  let ks = o.keys().collect()
  ks.sort_by(ref_cmp_str)
  ks
}

///|
/// jq's documented total order: null < false < true < numbers < strings <
/// arrays < objects; arrays lexicographically; objects first by their sorted
/// key arrays, then value by value in sorted key order.
fn ref_cmp(a : Json, b : Json) -> Int {
  let ra = type_rank(a)
  let rb = type_rank(b)
  if ra != rb {
    return ra.compare(rb)
  }
  match (a, b) {
    (Number(x, ..), Number(y, ..)) =>
      if x < y {
        -1
      } else if x > y {
        1
      } else {
        0
      }
    (String(x), String(y)) => ref_cmp_str(x, y)
    (Array(x), Array(y)) => {
      let n = if x.length() < y.length() { x.length() } else { y.length() }
      for i in 0..<n {
        let c = ref_cmp(x[i], y[i])
        if c != 0 {
          return c
        }
      }
      x.length().compare(y.length())
    }
    (Object(x), Object(y)) => {
      let kx = ref_sorted_keys(x)
      let ky = ref_sorted_keys(y)
      let n = if kx.length() < ky.length() { kx.length() } else { ky.length() }
      for i in 0..<n {
        let c = ref_cmp_str(kx[i], ky[i])
        if c != 0 {
          return c
        }
      }
      let c = kx.length().compare(ky.length())
      if c != 0 {
        return c
      }
      for k in kx {
        let c = ref_cmp(x.get(k).unwrap(), y.get(k).unwrap())
        if c != 0 {
          return c
        }
      }
      0
    }
    _ => 0
  }
}

///|
fn ref_truthy(v : Json) -> Bool {
  !(v is (Null | False))
}

///|
/// Structural equality that also requires object keys in the same order.
fn same_ordered(a : Json, b : Json) -> Bool {
  match (a, b) {
    (Object(x), Object(y)) => {
      let kx = x.keys().collect()
      let ky = y.keys().collect()
      kx == ky &&
      kx.iter().all(k => same_ordered(x.get(k).unwrap(), y.get(k).unwrap()))
    }
    (Array(x), Array(y)) =>
      x.length() == y.length() &&
      (0).until(x.length()).all(i => same_ordered(x[i], y[i]))
    _ => a == b
  }
}

///|
/// Pre-order enumeration of the non-empty paths of `v` (jq's `paths`).
fn ref_paths(v : Json) -> Array[Array[Json]] {
  let out : Array[Array[Json]] = []
  fn go(v : Json, prefix : Array[Json]) {
    match v {
      Array(a) =>
        for i, x in a {
          let p = prefix + [Json::number(i.to_double())]
          out.push(p)
          go(x, p)
        }
      Object(o) =>
        for k, x in o {
          let p = prefix + [Json::string(k)]
          out.push(p)
          go(x, p)
        }
      _ => ()
    }
  }

  go(v, [])
  out
}

///|
/// Pre-order enumeration of all sub-values of `v` (jq's `..`).
fn ref_descendants(v : Json) -> Array[Json] {
  let out : Array[Json] = []
  fn go(v : Json) {
    out.push(v)
    match v {
      Array(a) => a.each(go)
      Object(o) => o.values().each(go)
      _ => ()
    }
  }

  go(v)
  out
}

///|
fn ref_sort(xs : Array[Json]) -> Array[Json] {
  let c = xs.copy()
  c.sort_by(ref_cmp)
  c
}

///|
fn is_sorted(xs : Array[Json]) -> Bool {
  (1).until(xs.length()).all(i => ref_cmp(xs[i - 1], xs[i]) <= 0)
}

///|
/// Multiset equality under jq's `==`.
fn same_multiset(xs : Array[Json], ys : Array[Json]) -> Bool {
  xs.length() == ys.length() &&
  ({
    let a = ref_sort(xs)
    let b = ref_sort(ys)
    (0).until(a.length()).all(i => ref_cmp(a[i], b[i]) == 0)
  })
}

///|
fn qjq(query : String, input : Json) -> Array[Json] raise {
  @moonjq.run_json(@moonjq.parse(query), input)
}

///|
/// Outcome of a query: `None` if it raised, otherwise its outputs.
fn jq_outcome(query : String, input : Json) -> Array[Json]? {
  Some(qjq(query, input)) catch {
    _ => None
  }
}

///|
fn outcome_equal(a : Array[Json]?, b : Array[Json]?) -> Bool {
  match (a, b) {
    (None, None) => true
    (Some(x), Some(y)) =>
      x.length() == y.length() &&
      (0).until(x.length()).all(i => same_ordered(x[i], y[i]))
    _ => false
  }
}

///|
fn show(v : Json) -> String {
  v.stringify()
}

///|
fn has_astral(v : Json) -> Bool {
  ref_descendants(v)
  .iter()
  .any(d => d is String(s) && s.iter().any(c => c.to_int() > 0xFFFF))
}

///|
fn depth_of(v : Json) -> Int {
  match v {
    Array(a) =>
      1 +
      a.iter().map(depth_of).fold(init=0, (m, d) => if d > m { d } else { m })
    Object(o) =>
      1 +
      o.values().map(depth_of).fold(init=0, (m, d) => if d > m { d } else { m })
    _ => 0
  }
}

///|
fn type_name(v : Json) -> String {
  match v {
    Null => "null"
    True | False => "boolean"
    Number(_) => "number"
    String(_) => "string"
    Array(_) => "array"
    Object(_) => "object"
  }
}

///|
/// Filters used to instantiate the higher-order laws. They cover single,
/// multiple and zero outputs, and filters that raise on some inputs.
let filter_pool : Array[String] = [
  ".", "type", "tojson", "[.]", "..", ".[]?", "(., .)", "{a: .}", "empty", "select(type == \"number\")",
  "length?", "keys?", "[.[]?]", "not", "sort?", "add?", "(1, null)", "tostring",
  ".[\"a\"]?",
]

// ---------------------------------------------------------------------------
// Properties
// ---------------------------------------------------------------------------

///|
test "qc: generator covers all JSON shapes" {
  // Distribution check for the JSON generator itself.
  @quickcheck.check(
    (_ : JV) => true,
    observe=jv => {
      [
        @quickcheck.label(type_name(jv.v)),
        @quickcheck.classify(depth_of(jv.v) >= 2, "nested (depth >= 2)"),
        @quickcheck.classify(has_astral(jv.v), "contains astral chars"),
        @quickcheck.classify(
          ref_descendants(jv.v)
          .iter()
          .any(d => d is String(s) && s.iter().any(c => c.to_int() < 0x20)),
          "contains control chars",
        ),
      ]
    },
    count=300,
    seed=1,
  )
}

///|
test "qc: run parses stringified JSON back to the same value" {
  @quickcheck.check(
    (jv : JV) => {
      let out = @moonjq.run(".", jv.v.stringify())
      out.length() == 1 && same_ordered(out[0], jv.v)
    },
    counterexample_context=jv => show(jv.v),
    count=300,
    seed=11,
  )
}

///|
test "qc: identity returns the input unchanged" {
  @quickcheck.check(
    (jv : JV) => {
      let out = qjq(".", jv.v)
      out.length() == 1 && same_ordered(out[0], jv.v)
    },
    seed=12,
  )
}

///|
test "qc: .[] yields container values in order" {
  @quickcheck.check(
    (jv : JV) => {
      let expected : Array[Json] = match jv.v {
        Array(a) => a
        Object(o) => o.values().collect()
        _ => return true
      }
      outcome_equal(jq_outcome("[.[]]", jv.v), Some([Json::array(expected)]))
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=13,
  )
}

///|
test "qc: map(f) == [.[] | f]" {
  @quickcheck.check(
    (input : (JV, UInt)) => {
      let (jv, fi) = input
      guard jv.v is (Array(_) | Object(_)) else { true }
      let f = filter_pool[pick_idx(fi, filter_pool.length())]
      outcome_equal(
        jq_outcome("map(\{f})", jv.v),
        jq_outcome("[.[] | \{f}]", jv.v),
      )
    },
    counterexample_context=input => {
      let (jv, fi) = input
      "f = \{filter_pool[pick_idx(fi, filter_pool.length())]}, input = \{show(jv.v)}"
    },
    count=300,
    seed=14,
  )
}

///|
test "qc: select keeps exactly the truthy elements" {
  let preds : Array[(String, (Json) -> Bool)] = [
    ("true", _ => true),
    ("false", _ => false),
    ("null", _ => false),
    ("0", _ => true),
    ("type == \"string\"", v => v is String(_)),
    (". == null", v => v is Null),
    (". != null", v => !(v is Null)),
    ("(type == \"number\") and (. > 0)", v => v is Number(n, ..) && n > 0.0),
    ("not", v => !ref_truthy(v)),
  ]
  @quickcheck.check(
    (input : (JV, UInt)) => {
      let (jv, pi) = input
      let (p, ref_pred) = preds[pick_idx(pi, preds.length())]
      let whole = jq_outcome("select(\{p})", jv.v)
      let expected_whole = if ref_pred(jv.v) { [jv.v] } else { [] }
      guard outcome_equal(whole, Some(expected_whole)) else { false }
      guard jv.v is Array(a) else { true }
      outcome_equal(
        jq_outcome("[.[] | select(\{p})]", jv.v),
        Some([Json::array(a.filter(ref_pred))]),
      )
    },
    counterexample_context=input => {
      let (jv, pi) = input
      "pred = \{preds[pick_idx(pi, preds.length())].0}, input = \{show(jv.v)}"
    },
    count=300,
    seed=15,
  )
}

///|
test "qc: pipe is associative and comma distributes over pipe" {
  @quickcheck.check(
    (input : (JV, UInt, UInt, UInt)) => {
      let (jv, i, j, k) = input
      let n = filter_pool.length()
      let a = filter_pool[pick_idx(i, n)]
      let b = filter_pool[pick_idx(j, n)]
      let c = filter_pool[pick_idx(k, n)]
      outcome_equal(
        jq_outcome("((\{a}) | (\{b})) | (\{c})", jv.v),
        jq_outcome("(\{a}) | ((\{b}) | (\{c}))", jv.v),
      ) &&
      outcome_equal(
        jq_outcome("((\{a}), (\{b})) | (\{c})", jv.v),
        jq_outcome("((\{a}) | (\{c})), ((\{b}) | (\{c}))", jv.v),
      )
    },
    counterexample_context=input => {
      let (jv, i, j, k) = input
      let n = filter_pool.length()
      "a = \{filter_pool[pick_idx(i, n)]}, b = \{filter_pool[pick_idx(j, n)]}, c = \{filter_pool[pick_idx(k, n)]}, input = \{show(jv.v)}"
    },
    count=300,
    seed=16,
  )
}

///|
test "qc: length agrees with the value" {
  @quickcheck.check(
    (jv : JV) => {
      let expected : Json? = match jv.v {
        Null => Some(Json::number(0.0))
        True | False => None
        Number(n, ..) => Some(Json::number(n.abs()))
        String(s) => Some(Json::number(s.to_array().length().to_double()))
        Array(a) => Some(Json::number(a.length().to_double()))
        Object(o) => Some(Json::number(o.length().to_double()))
      }
      outcome_equal(jq_outcome("length", jv.v), expected.map(e => [e]))
    },
    counterexample_context=jv => show(jv.v),
    count=300,
    seed=17,
  )
}

///|
test "qc: keys lists exactly the object keys, and array indices" {
  // Note: moonjq documents that `keys` keeps insertion order (FEATURES.md and
  // integration_builtins_test), unlike jq which sorts. The order-independent
  // part of the contract is asserted here; `keys | sort` must be sorted.
  @quickcheck.check(
    (jv : JV) => {
      match jv.v {
        Object(o) => {
          let expected = o.keys().map(Json::string).collect()
          let sorted = ref_sorted_keys(o).map(Json::string)
          outcome_equal(jq_outcome("keys", jv.v), Some([Json::array(expected)])) &&
          outcome_equal(
            jq_outcome("keys | sort", jv.v),
            Some([Json::array(sorted)]),
          )
        }
        Array(a) => {
          let expected = Array::makei(a.length(), i => {
            Json::number(i.to_double())
          })
          outcome_equal(jq_outcome("keys", jv.v), Some([Json::array(expected)]))
        }
        _ => jq_outcome("keys", jv.v) is None
      }
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=18,
  )
}

///|
test "qc: to_entries | from_entries round-trips objects" {
  @quickcheck.check(
    (jv : JV) => {
      guard jv.v is Object(o) else { true }
      let entries = o
        .iter()
        .map(kv => Json::object({ "key": Json::string(kv.0), "value": kv.1 }))
        .collect()
      outcome_equal(
        jq_outcome("to_entries", jv.v),
        Some([Json::array(entries)]),
      ) &&
      outcome_equal(jq_outcome("to_entries | from_entries", jv.v), Some([jv.v])) &&
      outcome_equal(jq_outcome("with_entries(.)", jv.v), Some([jv.v]))
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=19,
  )
}

///|
test "qc: add over numbers equals a reference left-to-right sum" {
  @quickcheck.check(
    (xs : Array[Int]) => {
      let nums = xs.map(x => Json::number(x.to_double() / 8.0))
      let expected = if nums.is_empty() {
        Json::null()
      } else {
        Json::number(xs.fold(init=0.0, (acc, x) => acc + x.to_double() / 8.0))
      }
      outcome_equal(jq_outcome("add", Json::array(nums)), Some([expected]))
    },
    count=200,
    seed=20,
  )
}

///|
test "qc: add concatenates strings and arrays" {
  @quickcheck.check(
    (jv : JV) => {
      let strings = ref_descendants(jv.v).filter(d => d is String(_))
      let arrays = ref_descendants(jv.v).filter(d => d is Array(_))
      let concat_str = strings.fold(init="", (acc, s) => {
        guard s is String(s) else { acc }
        acc + s
      })
      let concat_arr : Array[Json] = []
      for a in arrays {
        guard a is Array(a) else { continue }
        concat_arr.append(a)
      }
      let expected_str = if strings.is_empty() {
        Json::null()
      } else {
        Json::string(concat_str)
      }
      let expected_arr = if arrays.is_empty() {
        Json::null()
      } else {
        Json::array(concat_arr)
      }
      outcome_equal(
        jq_outcome("add", Json::array(strings)),
        Some([expected_str]),
      ) &&
      outcome_equal(
        jq_outcome("add", Json::array(arrays)),
        Some([expected_arr]),
      )
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=21,
  )
}

///|
test "qc: sort is sorted, a permutation, and idempotent" {
  @quickcheck.check(
    (jv : JV) => {
      let xs = ref_descendants(jv.v)
      guard jq_outcome("sort", Json::array(xs)) is Some([Array(sorted)]) else {
        false
      }
      is_sorted(sorted) &&
      same_multiset(sorted, xs) &&
      outcome_equal(
        jq_outcome("sort | sort", Json::array(xs)),
        Some([Json::array(sorted)]),
      )
    },
    counterexample_context=jv => show(Json::array(ref_descendants(jv.v))),
    count=300,
    seed=22,
  )
}

///|
test "qc: unique is sorted and deduplicated" {
  @quickcheck.check(
    (jv : JV) => {
      // Duplicate some sub-values so dedup has work to do.
      let base = ref_descendants(jv.v)
      let xs = base + base.filter(d => d is (Object(_) | Array(_) | String(_)))
      let expected : Array[Json] = []
      for x in ref_sort(xs) {
        if expected.last() is Some(prev) && ref_cmp(prev, x) == 0 {
          continue
        }
        expected.push(x)
      }
      guard jq_outcome("unique", Json::array(xs)) is Some([Array(u)]) else {
        false
      }
      u.length() == expected.length() &&
      (0).until(u.length()).all(i => ref_cmp(u[i], expected[i]) == 0)
    },
    counterexample_context=jv => show(Json::array(ref_descendants(jv.v))),
    count=300,
    seed=23,
  )
}

///|
test "qc: comparison operators follow jq's total order" {
  @quickcheck.check(
    (p : JPair) => {
      let c = ref_cmp(p.a, p.b)
      let input = Json::array([p.a, p.b])
      outcome_equal(
        jq_outcome(
          "[.[0] < .[1], .[0] <= .[1], .[0] == .[1], .[0] != .[1], .[0] > .[1], .[0] >= .[1]]",
          input,
        ),
        Some([
          Json::array([
            Json::boolean(c < 0),
            Json::boolean(c <= 0),
            Json::boolean(c == 0),
            Json::boolean(c != 0),
            Json::boolean(c > 0),
            Json::boolean(c >= 0),
          ]),
        ]),
      ) &&
      outcome_equal(
        jq_outcome("[min, max]", input),
        Some([Json::array(if c <= 0 { [p.a, p.b] } else { [p.b, p.a] })]),
      )
    },
    observe=p => {
      let c = ref_cmp(p.a, p.b)
      [
        @quickcheck.label(
          if c < 0 {
            "a < b"
          } else if c == 0 {
            "a == b"
          } else {
            "a > b"
          },
        ),
        @quickcheck.classify(type_rank(p.a) == type_rank(p.b), "same type"),
        @quickcheck.classify(
          p.a is Object(_) && p.b is Object(_),
          "both objects",
        ),
      ]
    },
    counterexample_context=p => "a = \{show(p.a)}, b = \{show(p.b)}",
    count=500,
    seed=24,
  )
}

///|
test "qc: tojson | fromjson round-trips" {
  @quickcheck.check(
    (jv : JV) => {
      guard jq_outcome("tojson", jv.v) is Some([String(text)]) else { false }
      // The text must be real JSON for the same value.
      let reparsed = @json.parse(text) catch { _ => return false }
      same_ordered(reparsed, jv.v) &&
      outcome_equal(jq_outcome("tojson | fromjson", jv.v), Some([jv.v]))
    },
    counterexample_context=jv => show(jv.v),
    count=300,
    seed=25,
  )
}

///|
test "qc: tostring is identity on strings and tojson otherwise" {
  @quickcheck.check(
    (jv : JV) => {
      match jv.v {
        String(_) => outcome_equal(jq_outcome("tostring", jv.v), Some([jv.v]))
        _ =>
          outcome_equal(
            jq_outcome("tostring", jv.v),
            jq_outcome("tojson", jv.v),
          ) &&
          outcome_equal(jq_outcome("tostring | fromjson", jv.v), Some([jv.v]))
      }
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=26,
  )
}

///|
test "qc: paths, path(..) and .. agree with a reference traversal" {
  @quickcheck.check(
    (jv : JV) => {
      let paths = ref_paths(jv.v).map(Json::array)
      outcome_equal(jq_outcome("[paths]", jv.v), Some([Json::array(paths)])) &&
      outcome_equal(
        jq_outcome("[path(..)]", jv.v),
        Some([Json::array([Json::array([])] + paths)]),
      ) &&
      outcome_equal(
        jq_outcome("[..]", jv.v),
        Some([Json::array(ref_descendants(jv.v))]),
      ) &&
      outcome_equal(
        jq_outcome("[path(..) as $p | getpath($p)]", jv.v),
        Some([Json::array(ref_descendants(jv.v))]),
      )
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=27,
  )
}

///|
test "qc: paths(f) is paths filtered by f on the value at the path" {
  @quickcheck.check(
    (jv : JV) => {
      let expected = ref_paths(jv.v).filter(p => {
        let q = jq_outcome("getpath(\{Json::array(p).stringify()})", jv.v)
        q is Some([Number(_)])
      })
      outcome_equal(
        jq_outcome("[paths(type == \"number\")]", jv.v),
        Some([Json::array(expected.map(Json::array))]),
      )
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=28,
  )
}

///|
test "qc: getpath after setpath on an existing path" {
  @quickcheck.check(
    (c : JPathCase) => {
      let input = Json::object({ "v": c.v, "p": c.path, "x": c.x })
      outcome_equal(
        jq_outcome(
          ".p as $p | .x as $x | .v | setpath($p; $x) | getpath($p)", input,
        ),
        Some([c.x]),
      ) &&
      outcome_equal(
        jq_outcome(".p as $p | .v | setpath($p; getpath($p))", input),
        Some([c.v]),
      )
    },
    counterexample_context=c => {
      "v = \{show(c.v)}, path = \{show(c.path)}, x = \{show(c.x)}"
    },
    count=200,
    seed=29,
  )
}

///|
test "qc: setpath on null builds the path" {
  @quickcheck.check(
    (c : FreshPath) => {
      let input = Json::object({ "p": Json::array(c.path), "x": c.x })
      outcome_equal(
        jq_outcome(
          ".p as $p | .x as $x | null | setpath($p; $x) | getpath($p)", input,
        ),
        Some([c.x]),
      )
    },
    observe=c => [@quickcheck.collect(c.path.length())],
    counterexample_context=c => {
      "path = \{show(Json::array(c.path))}, x = \{show(c.x)}"
    },
    count=200,
    seed=30,
  )
}

///|
/// Render a path as a filter such as `.["a"][0]`.
fn path_filter(path : Array[Json]) -> String {
  "." + path.map(seg => "[\{seg.stringify()}]").join("")
}

///|
/// Replace every number in `v` by `f(n)`, keeping the shape and key order.
fn ref_map_numbers(v : Json, f : (Double) -> Double) -> Json {
  match v {
    Number(n, ..) => Json::number(f(n))
    Array(a) => Json::array(a.map(x => ref_map_numbers(x, f)))
    Object(o) => {
      let out : Map[String, Json] = Map([])
      for k, x in o {
        out[k] = ref_map_numbers(x, f)
      }
      Json::object(out)
    }
    _ => v
  }
}

///|
test "qc: filters built from paths agree with getpath and path" {
  @quickcheck.check(
    (c : JPathCase) => {
      guard c.path is Array(p) else { false }
      let f = path_filter(p)
      let input = Json::object({ "v": c.v, "p": c.path, "x": c.x })
      outcome_equal(
        jq_outcome(f, c.v),
        jq_outcome("getpath(\{c.path.stringify()})", c.v),
      ) &&
      outcome_equal(jq_outcome("path(\{f})", c.v), Some([c.path])) &&
      outcome_equal(
        jq_outcome(".x as $x | .v | (\{f}) = $x", input),
        jq_outcome(".p as $p | .x as $x | .v | setpath($p; $x)", input),
      )
    },
    observe=c => {
      [
        @quickcheck.collect(
          match c.path {
            Array(p) => p.length()
            _ => -1
          },
        ),
      ]
    },
    counterexample_context=c => {
      "v = \{show(c.v)}, path = \{show(c.path)}, x = \{show(c.x)}"
    },
    count=200,
    seed=32,
  )
}

///|
test "qc: p = $x sets exactly the paths of p" {
  @quickcheck.check(
    (jv : JV) => {
      outcome_equal(
        jq_outcome("(.. | select(type == \"number\")) = 0", jv.v),
        Some([ref_map_numbers(jv.v, _ => 0.0)]),
      )
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=33,
  )
}

///|
test "qc: p |= f equals setpath over path(p)" {
  @quickcheck.check(
    (jv : JV) => {
      let wrapped = match jv.v {
        Array(a) => Json::array(a.map(x => Json::array([x])))
        Object(o) => {
          let out : Map[String, Json] = Map([])
          for k, x in o {
            out[k] = Json::array([x])
          }
          Json::object(out)
        }
        other => other
      }
      outcome_equal(
        jq_outcome("(.. | select(type == \"number\")) |= . + 1", jv.v),
        Some([ref_map_numbers(jv.v, n => n + 1.0)]),
      ) &&
      outcome_equal(jq_outcome(".[]? |= [.]", jv.v), Some([wrapped])) &&
      outcome_equal(
        jq_outcome(".[]? |= [.]", jv.v),
        jq_outcome(
          "reduce path(.[]?) as $p (.; setpath($p; getpath($p) | [.]))",
          jv.v,
        ),
      )
    },
    counterexample_context=jv => show(jv.v),
    count=200,
    seed=34,
  )
}

///|
/// Tokens used to perturb generated queries. Looping constructs and
/// recursive definitions are left out so every query terminates.
let query_tokens : Array[String] = [
  ".", "..", "[", "]", "{", "}", "(", ")", "|", ",", ":", ";", "?", "//", "+", "-",
  "*", "/", "%", "==", "!=", "<", ">=", "and", "or", "not", "if", "then", "elif",
  "else", "end", "try", "catch", "as", "$x", ".a", ".[0]", ".[]", ".[1:]", "\"s\"",
  "\"\\(.)\"", "\"\\u00e9\"", "1", "-1", "2.5", "null", "true", "map(", "select(",
  "length", "keys", "add", "sort", "unique", "to_entries", "from_entries", "tojson",
  "fromjson", "paths", "getpath(", "setpath(", "@base64", "@csv", "type", "reduce",
  "first", "empty", "path(", "tostring", "|=", "=", "+=", "\"😀\"", ".\"k\"", ".[\"k\"]",
]

///|
let query_atoms : Array[String] = [
  ".", "..", ".a", ".[0]", ".[-1]", ".[]", ".[]?", ".[1:]", ".\"k\"", ".[\"😀\"]",
  "1", "null", "\"s\"", "\"\\u00e9\\(.)\"", "$x", "length", "keys", "tojson", "tostring",
  "add", "sort", "unique", "to_entries", "from_entries", "type", "empty", "not",
  "first", "@base64", "@json", "paths",
]

///|
/// Generate a syntactically valid jq query as a token list. Every operand
/// of a binary operator is parenthesised, so the output is valid jq
/// regardless of precedence.
fn gen_query(rs : @quickcheck.RandomState, depth : Int) -> Array[String] {
  if depth <= 0 || rand_below(rs, 10) < 3 {
    return [query_atoms[rand_below(rs, query_atoms.length())]]
  }
  let sub = () => gen_query(rs, depth - 1)
  let paren = (e : Array[String]) => ["("] + e + [")"]
  match rand_below(rs, 13) {
    0 => ["map", "("] + sub() + [")"]
    1 => ["select", "("] + sub() + [")"]
    2 => ["path", "("] + sub() + [")"]
    3 => ["["] + sub() + ["]"]
    4 => ["{", "a", ":"] + paren(sub()) + ["}"]
    5 => paren(sub()) + ["?"]
    6 => ["if"] + sub() + ["then"] + sub() + ["else"] + sub() + ["end"]
    7 => paren(sub()) + ["as", "$x", "|"] + paren(sub())
    8 => ["try"] + paren(sub())
    9 =>
      ["reduce"] +
      paren(sub()) +
      ["as", "$x", "("] +
      sub() +
      [";"] +
      sub() +
      [")"]
    _ => {
      let ops = ["|", ",", "+", "-", "==", "<", "and", "//", "|=", "=", "+="]
      paren(sub()) + [ops[rand_below(rs, ops.length())]] + paren(sub())
    }
  }
}

///|
/// A generated query: grammar output, optionally perturbed by deleting or
/// inserting one token so that invalid queries are exercised too.
struct QuerySrc {
  tokens : Array[String]
  mutated : Bool
} derive(Debug)

///|
fn QuerySrc::text(self : QuerySrc) -> String {
  self.tokens.join(" ")
}

///|
impl @quickcheck.Arbitrary for QuerySrc with fn arbitrary(size, rs) {
  let tokens = gen_query(rs, if size < 20 { 1 + size / 5 } else { 4 })
  match rand_below(rs, 3) {
    0 => {
      tokens.remove(rand_below(rs, tokens.length())) |> ignore
      { tokens, mutated: true, }
    }
    1 => {
      tokens.insert(
        rand_below(rs, tokens.length() + 1),
        query_tokens[rand_below(rs, query_tokens.length())],
      )
      { tokens, mutated: true, }
    }
    _ => { tokens, mutated: false, }
  }
}

///|
impl @quickcheck.Shrink for QuerySrc with fn shrink(self) {
  // Only mutated queries may lose tokens; valid ones must stay valid.
  if !self.mutated {
    return Iter::empty()
  }
  Array::makei(self.tokens.length(), i => {
    let t = self.tokens.copy()
    t.remove(i) |> ignore
    { tokens: t, mutated: true, }
  }).iter()
}

///|
fn parses(query : String) -> Bool {
  try @moonjq.parse(query) catch {
    _ => false
  } noraise {
    _ => true
  }
}

///|
test "qc: generated queries parse, evaluate without aborting, and parse whole" {
  @quickcheck.check(
    (input : (QuerySrc, JV)) => {
      let (src, jv) = input
      let q = src.text()
      // Evaluation may raise but must not abort the process.
      let _ = jq_outcome(q, jv.v)
      let ok = parses(q)
      // Grammar output is valid jq, and a query that parses must use every
      // token: appending an unmatched `)` has to make it a parse error.
      (src.mutated || ok) && (!ok || !parses(q + " )"))
    },
    observe=input => {
      let (src, _) = input
      [
        @quickcheck.classify(src.mutated, "mutated"),
        @quickcheck.classify(parses(src.text()), "parses"),
        @quickcheck.classify(src.tokens.length() > 10, "more than 10 tokens"),
      ]
    },
    counterexample_context=input => input.0.text(),
    count=500,
    seed=31,
  )
}

///|
fn pick_idx(i : UInt, n : Int) -> Int {
  (i % n.reinterpret_as_uint()).reinterpret_as_int()
}
