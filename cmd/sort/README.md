# sort for moonx

Sort lines of files or stdin:

```sh
moonx bobzhang/sort names.txt
printf '10\n2\n' | moonx bobzhang/sort -n
moonx bobzhang/sort -t, -k 2 -u data.csv
```

Options: `-r` reverse, `-n` numeric (by leading number of the key), `-u`
unique by key, `-f` fold case, `-k START[,END]` sort by a field range
(1-based, whole fields), `-t CHAR` field separator (default: runs of
blanks). The sort is stable; strings compare by UTF-16 code units.
