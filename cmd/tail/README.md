# tail for moonx

Print the last lines or bytes of files or stdin:

```sh
printf '1\n2\n3\n4\n' | moonx bobzhang/tail -n 2
printf '1\n2\n3\n4\n' | moonx bobzhang/tail -n +3   # from line 3 to the end
moonx bobzhang/tail -n 100 huge.log
```

Options: `-n N` last N lines (default 10), `-n +K` from line K, `-c N` last
N bytes, `-c +K` from byte K, `-q`/`-v` header control.

Regular files are read GNU-style from the end in fixed-size chunks, so
memory stays constant for any file size — a multi-gigabyte log tails
instantly, on the wasm target included. Stdin and pipes are streamed with a
ring buffer that holds only the selected suffix. There is no `-f` (follow)
mode.
