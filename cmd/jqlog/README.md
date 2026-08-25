# jqlog

`bobzhang/jqlog` is the native JSON Lines companion command in the MoonJQ
workspace. It applies a jq-compatible filter to each valid JSON line and skips
non-JSON lines.

```sh
cat logs.ndjson | moon run --target native cmd/jqlog -- '.message'
```
