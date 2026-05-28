# MoonJQ CLI

These tests exercise the native `moonjq` command-line surface. The runner
builds the CLI and exposes it as `MOONJQ_CLI`.

## File Input

```mooncram
$ printf '%s' '{"name":"Moon","items":[1,2,3],"nested":{"ok":true}}' > data.json && "$MOONJQ_CLI" -c '.items[]' data.json
1
2
3
```

```mooncram
$ printf '%s' '{"name":"Moon","items":[1,2,3],"nested":{"ok":true}}' > data.json && "$MOONJQ_CLI" -r '.name' data.json
Moon
```

## Stdin And Null Input

```mooncram
$ printf '{"nested":{"ok":true}}' | "$MOONJQ_CLI" '.nested'
{
  "ok": true
}
```

```mooncram
$ printf '{"nested":{"ok":true}}' | "$MOONJQ_CLI" -c '.nested'
{"ok":true}
```

```mooncram
$ "$MOONJQ_CLI" -n -c '{ok: true, values: [1, 2]}'
{"ok":true,"values":[1,2]}
```

## Multiple Inputs

```mooncram
$ printf '%s' '{"name":"Ada"}' > a.json && printf '%s' '{"name":"Grace"}' > b.json && printf '%s' '{"name":"Lin"}' | "$MOONJQ_CLI" -r '.name' a.json - b.json
Ada
Lin
Grace
```

## Filter Files

```mooncram
$ printf '%s' '{"users":[{"name":"Ada","active":true},{"name":"Grace","active":false}]}' > data.json && printf '%s\n' '.users[] | select(.active) | .name' > filter.jq && "$MOONJQ_CLI" -r -f filter.jq data.json
Ada
```

## Logs

```mooncram
$ printf '%s\n' '{"level":"info","message":"started"}' 'not json' '{"level":"error","message":"failed"}' > logs.ndjson && "$MOONJQ_CLI" --logs -r 'select(.level == "error") | .message' logs.ndjson
failed
```

## Errors

```mooncram
$ "$MOONJQ_CLI" --missing >/dev/null 2>&1
[2]
```

```mooncram
$ "$MOONJQ_CLI" --logs -n '.' >/dev/null 2>&1
[2]
```

```mooncram
$ "$MOONJQ_CLI" -f missing.jq >/dev/null 2>&1
[2]
```

```mooncram
$ printf '{"x":1}' | "$MOONJQ_CLI" '[' >/dev/null 2>&1
[3]
```

```mooncram
$ printf 'not json' | "$MOONJQ_CLI" '.' >/dev/null 2>&1
[5]
```
