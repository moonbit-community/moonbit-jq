# comm for moonx

Compare two sorted files line by line, producing three columns: lines only
in FILE1, lines only in FILE2 (one leading TAB), and common lines (two
leading TABs):

```sh
moonx bobzhang/comm left.txt right.txt
moonx bobzhang/comm -12 left.txt right.txt   # only common lines
```

Options: `-1`, `-2`, `-3` suppress the corresponding column (combinable as
`-12`, `-23`, ...). Use `-` to read stdin. Lines are compared by UTF-16
code units, matching `LC_ALL=C` order for ASCII data.
