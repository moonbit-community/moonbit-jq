# MoonJQ CLI

These tests exercise the native `moonjq` command-line surface. `moon cram`
builds the workspace first and puts the built CLI binaries in `PATH`, so the
tests call `jq.exe` directly.

## File Input

```mooncram
$ printf '%s' '{"name":"Moon","items":[1,2,3],"nested":{"ok":true}}' > data.json && jq.exe -c '.items[]' data.json
1
2
3
```

```mooncram
$ printf '%s' '{"name":"Moon","items":[1,2,3],"nested":{"ok":true}}' > data.json && jq.exe -r '.name' data.json
Moon
```

## Stdin And Null Input

```mooncram
$ printf '{"nested":{"ok":true}}' | jq.exe '.nested'
{
  "ok": true
}
```

```mooncram
$ printf '{"nested":{"ok":true}}' | jq.exe -c '.nested'
{"ok":true}
```

```mooncram
$ jq.exe -n -c '{ok: true, values: [1, 2]}'
{"ok":true,"values":[1,2]}
```

## Multiple Inputs

```mooncram
$ printf '%s' '{"name":"Ada"}' > a.json && printf '%s' '{"name":"Grace"}' > b.json && printf '%s' '{"name":"Lin"}' | jq.exe -r '.name' a.json - b.json
Ada
Lin
Grace
```

## Filter Files

```mooncram
$ printf '%s' '{"users":[{"name":"Ada","active":true},{"name":"Grace","active":false}]}' > data.json && printf '%s\n' '.users[] | select(.active) | .name' > filter.jq && jq.exe -r -f filter.jq data.json
Ada
```

## Logs

```mooncram
$ printf '%s\n' '{"level":"info","message":"started"}' 'not json' '{"level":"error","message":"failed"}' > logs.ndjson && jq.exe --logs -r 'select(.level == "error") | .message' logs.ndjson
failed
```

## Errors

```mooncram
$ jq.exe --missing >/dev/null 2>&1
[2]
```

```mooncram
$ jq.exe --logs -n '.' >/dev/null 2>&1
[2]
```

```mooncram
$ jq.exe -f missing.jq >/dev/null 2>&1
[2]
```

```mooncram
$ printf '{"x":1}' | jq.exe '[' >/dev/null 2>&1
[3]
```

```mooncram
$ printf 'not json' | jq.exe '.' >/dev/null 2>&1
[5]
```
