# MoonJQ CLI

These tests exercise the local `bobzhang/jq` command-line surface. Run them
from its module directory so mooncram builds the checked-out implementation:

```sh
cd cmd/jq
moonx moonbit-community/mooncram@0.1.0 test ../../tests/cram/cli.md
```

The default backend is Wasm; add `--target native` to test the native backend.
Input files live in `fixtures/`, relative to this document. Pipeline helpers
use pinned tools from the Mooncakes `cli` account.

## File Input

```mooncram bobzhang/jq
$ moonx bobzhang/jq -c '.items[]' fixtures/data.json
1
2
3
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq -r '.name' fixtures/data.json
Moon
```

## Stdin And Null Input

```mooncram bobzhang/jq
$ moonx cli/printf@0.2.1 '{"nested":{"ok":true}}' | moonx bobzhang/jq '.nested'
{
  "ok": true
}
```

```mooncram bobzhang/jq
$ moonx cli/printf@0.2.1 '{"nested":{"ok":true}}' | moonx bobzhang/jq -c '.nested'
{"ok":true}
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq -n -c '{ok: true, values: [1, 2]}'
{"ok":true,"values":[1,2]}
```

## Multiple Inputs

```mooncram bobzhang/jq
$ moonx cli/printf@0.2.1 '%s' '{"name":"Lin"}' | moonx bobzhang/jq -r '.name' fixtures/a.json - fixtures/b.json
Ada
Lin
Grace
```

## Filter Files

```mooncram bobzhang/jq
$ moonx bobzhang/jq -r -f fixtures/filter.jq fixtures/users.json
Ada
```

## Logs

```mooncram bobzhang/jq
$ moonx bobzhang/jq --logs -r 'select(.level == "error") | .message' fixtures/logs.ndjson
failed
```

## Errors

```mooncram bobzhang/jq
$ moonx bobzhang/jq --missing
[2]
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq --logs -n '.'
[2]
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq -f fixtures/missing.jq
[2]
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq '[' fixtures/data.json
[3]
```

```mooncram bobzhang/jq
$ moonx cli/printf@0.2.1 'not json' | moonx bobzhang/jq '.'
[5]
```

## Suspended Evaluation And Terminal Errors

```mooncram bobzhang/jq
$ moonx bobzhang/jq -n -c 'limit(3; repeat(.))'
null
null
null
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq -n -c 'limit(1; (1, ({} + 1)))'
1
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq -n -c '1, error("failed"), 2'
1
[5]
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq -n -c '"\(. 1)"'
[3]
```

```mooncram bobzhang/jq
$ moonx bobzhang/jq -n -c 'missing_function'
[3]
```
