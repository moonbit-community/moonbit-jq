# head for moonx

Print the first lines or bytes of files or stdin:

```sh
printf '1\n2\n3\n' | moonx bobzhang/head -n 2
moonx bobzhang/head -c 16 data.bin
```

Options: `-n N` first N lines (default 10), `-c N` first N bytes, `-q`/`-v`
control the `==> file <==` headers shown for multiple files.
