# jq for moonx

Run jq-compatible JSON filters without installing a separate binary:

```sh
printf '%s' '{"name":"Moon"}' | moonx moonbit-community/jq -r '.name'
moonx moonbit-community/jq -n -c '{ok: true, values: [1, 2]}'
moonx moonbit-community/jq -c '.items[]' data.json
```

`moonx` uses the linear-memory WebAssembly build by default. Arguments after
`moonbit-community/jq` are passed directly to the jq-compatible command.

Supported options:

- `-c`, `--compact-output`: print compact JSON.
- `-r`, `--raw-output`: print strings without JSON quotes.
- `-f`, `--from-file FILE`: read the filter from `FILE`.
- `-n`, `--null-input`: evaluate once with `null` input.
- `-l`, `--logs`: process newline-delimited JSON and skip invalid lines.
- `-h`, `--help`: show the generated command help.

Arguments are parsed with `moonbitlang/core/argparse`. Short flags can be
combined, as in `-nrc`, and `--from-file=FILE` is supported. Use `--` before a
filter or filename beginning with a hyphen. Invalid arguments exit with status 2.

Query syntax and binding errors exit with status 3. Runtime errors print a
diagnostic and exit with status 5, retaining results already printed. `--logs`
skips invalid JSON lines and still reports query failures.
