# nl for moonx

Number lines of files or stdin:

```sh
printf 'alpha\nbeta\n' | moonx bobzhang/nl
moonx bobzhang/nl -b a -w 3 -s ' ' notes.txt
```

Options: `-b a|t|n` number all/nonempty/no lines (default `t`), `-w N`
number width (default 6), `-s SEP` separator (default TAB). Unnumbered
lines are indented by the number width. Numbering is continuous across
multiple files.
