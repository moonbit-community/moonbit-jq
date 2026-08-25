# tail for moonx

Print the last lines or bytes of files or stdin:

```sh
printf '1\n2\n3\n4\n' | moonx bobzhang/tail -n 2
printf '1\n2\n3\n4\n' | moonx bobzhang/tail -n +3   # from line 3 to the end
```

Options: `-n N` last N lines (default 10), `-n +K` from line K, `-c N` last
N bytes, `-c +K` from byte K, `-q`/`-v` header control. There is no `-f`
(follow) mode: input is read to EOF.
