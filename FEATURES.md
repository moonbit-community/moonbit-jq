# MoonJQ Feature Status

This describes the implementation in the current checkout. The frontend and
streaming runtime target jq 1.7.1 semantics within the scope covered by the
[semantic acceptance suite](tests/semantics/README.md). Compatibility limits and
extensions are listed below.

## Query Language

| Area | Supported forms |
| --- | --- |
| Access | `.`, `.field`, `."field"`, `.[expr]`, negative indices, `.[]`, array/string slices |
| Composition | Pipes (`\|`), multiple outputs (`,`), parentheses, recursive descent (`..`) |
| Construction | JSON literals, `[filter]`, object constructors, shorthand fields, computed keys |
| Arithmetic | `+`, `-`, `*`, `/`, `%`, unary minus; type-dependent JSON operations |
| Comparison and logic | `==`, `!=`, `<`, `<=`, `>`, `>=`, `and`, `or`, `not`, `//` |
| Conditionals and errors | `if ... then ... elif ... else ... end`, `try ... catch ...`, `?` |
| Binding | `expr as $var \| body`, lexical variable scope |
| Aggregation | `reduce expr as $var (init; update)`, `foreach expr as $var (init; update)`, `foreach expr as $var (init; update; extract)` |
| Assignment | `=`, `\|=`, `+=`, `-=`, `*=`, `/=`, `%=`, `//=` on field, index, iteration, and slice paths |
| Functions | `def name: body;`, filter and `$value` parameters, lexical scope, recursive calls |
| Strings and comments | Escapes, `\(expr)` interpolation, nested interpolation, `#` line comments |

Only `false` and `null` are falsy. Arithmetic follows the operand types; explicit
conversion is available through `tostring` and `fromjson`.

## Built-in Functions

These are the names and argument forms registered in
[runtime/builtin_registry.mbt](runtime/builtin_registry.mbt). Arguments are
separated by semicolons; `f`, `g`, and `cond` denote filters. The
[runtime documentation](runtime/README.mbt.md) explains argument evaluation order
and stream consumption.

| Area | Supported forms |
| --- | --- |
| Inspection | `length`, `type`, `keys`, `keys_unsorted` |
| Type filters | `values`, `numbers`, `strings`, `scalars`, `booleans`, `nulls`, `arrays`, `objects`, `iterables` |
| Stream and error primitives | `empty`, `not`, `error`, `error(value)` |
| Mapping and selection | `map(f)`, `map_values(f)`, `select(f)`, `with_entries(f)` |
| Entries and membership | `to_entries`, `from_entries`, `has(key)`, `in(container)` |
| Containment | `contains(value)`, `inside(value)` |
| Ordering and aggregation | `sort`, `reverse`, `unique`, `add`, `min`, `max`, `sort_by(f)`, `group_by(f)`, `unique_by(f)`, `min_by(f)`, `max_by(f)` |
| Array structure | `flatten`, `flatten(depth)`, `combinations`, `transpose` |
| Ranges | `range(end)`, `range(start; end)`, `range(start; end; step)` |
| First, last, and nth | `first`, `first(g)`, `last`, `last(g)`, `nth(n)`, `nth(n; g)` |
| Predicates | `any`, `any(cond)`, `any(g; cond)`, `all`, `all(cond)`, `all(g; cond)` |
| Recursion and traversal | `recurse`, `recurse(f)`, `recurse(f; cond)`, `walk(f)` |
| Path enumeration | `paths`, `paths(f)`, `leaf_paths` |
| Path access and mutation | `path(f)`, `getpath(path)`, `setpath(path; value)`, `delpaths(paths)` |
| Loops and limits | `repeat(f)`, `limit(n; g)`, `until(cond; f)`, `while(cond; f)` |
| String operations | `split(separator)`, `join(separator)`, `startswith(prefix)`, `endswith(suffix)`, `ltrimstr(prefix)`, `rtrimstr(suffix)` |
| Case conversion | `ascii_downcase`, `ascii_upcase` |
| Search | `indices(value)`, `index(value)`, `rindex(value)` |
| Character conversion | `explode`, `implode` |
| JSON and text conversion | `tojson`, `fromjson`, `tostring` |
| Numeric operations | `floor`, `ceil`, `round`, `abs`, `sqrt`, `pow(base; exponent)`, `pow(exponent)` |
| Math functions | `log`, `exp`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan` |

`values` filters out `null`; object values can be emitted with `.[]`.
`keys` sorts object keys by Unicode code point; `keys_unsorted` preserves the
map's iteration order.

### Formats

Standalone format filters are implemented in
[runtime/value_format.mbt](runtime/value_format.mbt):

- `@text`, `@json`, `@html`, `@uri`
- `@csv`, `@tsv`
- `@base64`, `@base64d`

`@csv` and `@tsv` accept arrays of scalar values. `@html`, `@uri`, and `@base64`
require string input. `@base64d` validates Base64 length and padding and requires
UTF-8 output.

### Partial Regex Support

The following names are available, with limited behavior:

| Forms | Current behavior |
| --- | --- |
| `test(pattern)` | Literal substring containment |
| `match(pattern)` | Literal containment with a match object; offset is always zero and captures are empty |
| `capture(pattern)` | Placeholder returning an empty object for string input |
| `scan(pattern)`, `splits(pattern)` | Literal substring scanning and splitting |
| `sub(pattern; replacement)`, `gsub(pattern; replacement)` | Literal string replacement |

Regex syntax, flags, named captures, and capture-based replacements remain
unimplemented. See [value_regex.mbt](runtime/value_regex.mbt) and
[value_string_scan.mbt](runtime/value_string_scan.mbt).

## Library and Command Line

- Queries compile into immutable plans and can be reused across independent or
  interleaved evaluations.
- `Query::eval` and `Query::eval_logs` return
  `Iter[Result[Json, EvalError]]`. Errors terminate the stream after preceding
  results; `eval_all` collects results and raises the first error. See the
  [public API](pkg.generated.mbti) and [stream tests](stream_protocol_test.mbt).
- Parse diagnostics and runtime errors carry source spans using UTF-16 offsets.
- The [jq](cmd/jq/README.md) and [jqlog](cmd/jqlog/README.md) commands support
  Native and Wasm builds, stdin/file input, and JSON Lines processing. `jq -l`
  and `jqlog` skip malformed JSON lines and report query failures.

Streaming consumers such as `first`, `limit`, and `nth` can stop early.
Collections, sorting, and grouping materialize the results they need; memory
usage depends on the query. See the [runtime](runtime/README.mbt.md) for details.

## Remaining Gaps and Compatibility Extensions

| Area | Current status |
| --- | --- |
| Query language | Module/import/include support, labels and `break`, destructuring bindings, and `?//` are unimplemented. `as` binds a single variable. |
| Formatted string literals | Format filters work independently; syntax such as `@uri "..."` is unimplemented. |
| Environment and input builtins | `env`, `$ENV`, `$__loc__`, `input`, and `inputs` are unimplemented. CLI input handling is provided separately. |
| Date/time | `now`, `fromdateiso8601`, `todateiso8601`, `fromdate`, `todate`, `strftime`, and `strptime` are unimplemented. |
| Additional math functions | Functions such as `log10`, `log2`, `exp10`, `exp2`, `sinh`, `cosh`, and `tanh` are unimplemented. |
| Additional overloads | Only the builtin argument forms listed above are registered; for example, `combinations(n)` is unimplemented. |
| Regex and encoding | Regex behavior is partial as described above. Base64 decoding is stricter than jq's. |
| Compatibility extensions | `leaf_paths` and the input-based `pow(exponent)` form are retained extensions to the jq 1.7.1 target. |

## Validation and Maintenance

- Parser and runtime tests live alongside their implementation packages.
- [Semantic acceptance](tests/semantics/README.md) documents the fixed jq 1.7.1
  reference cases, generated comparisons, exclusions, and regeneration commands.
- [Stream tests](stream_protocol_test.mbt) cover lazy evaluation, terminal errors,
  independent evaluation state, and early termination.
- [CLI tests](tests/cram/cli.md), [jqlog tests](tests/cram/jqlog.md), and the
  [tutorial](TUTORIAL.md) contain executable mooncram examples. CI runs them with
  both Wasm and Native backends.

Keep this list in sync with parser syntax, the builtin registry, format dispatch,
and their tests when changing supported features. Use test output for current
pass counts.
