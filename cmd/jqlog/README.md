# jqlog

`moonbit-community/jqlog` is the Native/Wasm JSON Lines companion command in the
MoonJQ workspace. It applies a jq-compatible filter to each valid JSON line and
skips non-JSON lines.

```sh
moonx moonbit-community/jqlog -f logs.ndjson '.message'
moonx moonbit-community/jqlog '.message' '{"message":"started"}'
```

Arguments are parsed with `moonbitlang/core/argparse`:

- `-f FILE`, `--file FILE`: read input from a file. `--file=FILE` is also accepted.
- `-h`, `--help`: show the generated command help.
- `--`: stop parsing options, allowing a query or input to begin with a hyphen.

The query is required. Omit input or pass `-` to read stdin; otherwise the
optional input argument is treated as inline JSONL text. File and inline input
are mutually exclusive. Options can appear before or after the query.

Malformed JSON lines are skipped. A query error terminates the result stream,
prints a diagnostic, and exits with status 5 after prior results. Query syntax
and binding errors exit with status 3; argument errors exit with status 2.
