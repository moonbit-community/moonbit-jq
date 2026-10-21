# jqlog

`bobzhang/jqlog` is the Native/Wasm JSON Lines companion command in the MoonJQ
workspace. It applies a jq-compatible filter to each valid JSON line and skips
non-JSON lines.

```sh
cat logs.ndjson | moon run --target native cmd/jqlog -- '.message'
```

Malformed JSON lines are skipped. A query error terminates the result stream,
prints a diagnostic, and exits with status 5 after prior results. Query syntax
and binding errors exit with status 3; argument errors exit with status 2.
