---
name: jq
description: Query, filter, transform, aggregate, and reshape JSON with the portable bobzhang/jq WebAssembly CLI. Use when Codex needs jq-compatible field extraction, array filtering or mapping, object construction, raw or compact output, JSONL/NDJSON processing, or JSON transformations from stdin or files without relying on a native jq installation.
---

# jq

Run the jq-compatible command directly from Mooncakes:

```sh
moonx bobzhang/jq [OPTIONS] '<filter>' [FILE...]
```

Put options before the filter. Pass the filter as one single-quoted shell
argument so `$`, pipes, parentheses, and quotes reach the command unchanged.
When no file is supplied, provide JSON on standard input.

## Workflow

1. Inspect the input shape and decide whether it is one JSON value, a JSON
   file, or newline-delimited JSON.
2. Write the smallest filter that produces the requested result.
3. Choose `-c` for machine-readable compact JSON or `-r` when the result must
   be an unquoted string.
4. Run the filter on representative input and check the exit status and output
   before using it in a larger pipeline.
5. If a complex jq feature is unsupported, simplify the filter into smaller
   pipes and report the compatibility limitation instead of silently changing
   the requested transformation.

## Common commands

Extract a field from standard input as raw text:

```sh
printf '%s' '{"user":{"name":"Moon"}}' \
  | moonx bobzhang/jq -r '.user.name // "unknown"'
```

Filter an array and construct smaller objects from a file:

```sh
moonx bobzhang/jq -c \
  '.items[] | select(.active) | {id: .id, name: .name}' data.json
```

Collect streaming results into one array:

```sh
moonx bobzhang/jq -c '[.items[] | .id]' data.json
```

Transform and aggregate values:

```sh
moonx bobzhang/jq -c '.values | map(. * 2) | add' data.json
```

Construct JSON without reading input:

```sh
moonx bobzhang/jq -n -c '{ok: true, values: [1, 2]}'
```

Process newline-delimited JSON logs and skip invalid lines:

```sh
moonx bobzhang/jq -l -r \
  'select(.level == "error") | .message' events.ndjson
```

Read a longer filter from a file:

```sh
moonx bobzhang/jq -f transform.jq data.json
```

## Options

- Use `-c` or `--compact-output` to emit one compact JSON value per result.
- Use `-r` or `--raw-output` to print string results without JSON quotes.
- Use `-n` or `--null-input` to evaluate once with `null` input.
- Use `-l` or `--logs` for JSONL/NDJSON and to skip non-JSON lines.
- Use `-f FILE` or `--from-file FILE` to load the filter from a file.
- Run `moonx bobzhang/jq --help` to inspect the current command synopsis.

Prefer an explicit version such as `bobzhang/jq@0.1.1` in reproducible scripts.
Use the unversioned `bobzhang/jq` coordinate when automatically following the
latest published version is desirable.
