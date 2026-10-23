# Semantic acceptance

`jq-1.7.1.json` records query, input, ordered output values, reference diagnostic
prefix, and exit status. Its SHA-256 identifies the Linux AMD64 reference binary
from the [jq 1.7.1 release](https://github.com/jqlang/jq/releases/tag/jq-1.7.1).
`jq-1.6-frontend.json` preserves the older frontend comparison separately.

Expected values are generated only by jq 1.7.1. `semantics_reference_test.mbt`
uses the fixture on every supported library backend. Legacy snapshot corrections
also use independently checked jq outputs via `assert_reference_query`.

The scripts require Node.js 20 or newer and use only its standard library.

```sh
node tests/semantics/reference.mjs --reference /path/to/jq-1.7.1 --check-reference
node tests/semantics/reference.mjs --implementation /path/to/jq.exe
node tests/semantics/reference.mjs --reference /path/to/jq-1.7.1 \
  --implementation /path/to/jq.exe --generate
node tests/semantics/reference.mjs --wasm-runner moonrun \
  --implementation /path/to/jq.wasm
```

To deliberately regenerate expectations after editing the case list:

```sh
node tests/semantics/reference.mjs --reference /path/to/jq-1.7.1 --refresh --write-moon
moon fmt
```

The deterministic generator uses seed 1701 and retains the previous Python
generator's 272 cases. Another 738 cases cross assignment lowering, value/filter
parameters and lexical shadowing, range argument order, nested containment,
interpolated fields, and slice writes/deletions. All 1,010 generated cases use
bounded syntax depth, finite leaves, and explicit limits. They compare output
counts, order, and termination status;
the fixed cases also require diagnostics on CLI errors. Interpolation/conversion
pairs are checked against jq, alongside a library equivalence property. Regex
algorithms, modules, and historical pure-operation extensions are outside this
acceptance set.

The fixed regressions include right-hand errors after successful outputs,
truthy and multi-path `//=`, distinct boolean kinds, original-input interpolation,
function definition captures, null slice creation, and overlapping slice paths
passed through both updates and `delpaths`. Library stream tests additionally
check early termination, repeated and interleaved evaluations, input immutability,
and UTF-16 locations after lowering.

The CLI checks verify that both commands retain preceding output (including its
newline), report errors, and skip malformed log lines:

```sh
node tests/semantics/cli_errors.mjs --jq /path/to/jq.exe --jqlog /path/to/jqlog.exe
```

Add `--wasm-runner moonrun` and supply `.wasm` paths to run the same assertions on
the Wasm commands.
