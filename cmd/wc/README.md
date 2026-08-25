# wc for moonx

Count lines, words, and bytes without installing anything:

```sh
printf 'one two\nthree\n' | moonx bobzhang/wc
moonx bobzhang/wc -l notes.txt
```

Options: `-l` lines, `-w` words, `-c` bytes, `-m` UTF-8 characters. With no
flags it prints lines, words, and bytes. Counts are separated by single
spaces (not column-aligned like GNU wc). Multiple files get a `total` row.
