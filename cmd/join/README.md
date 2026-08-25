# join for moonx

Join lines of two files sorted on their join fields:

```sh
moonx bobzhang/join people.txt colors.txt
moonx bobzhang/join -t, -1 2 -2 1 a.csv b.csv
```

Options: `-1 N` / `-2 N` choose the join field in each file (default 1),
`-t CHAR` field separator (default: runs of blanks, output separated by a
single space). Only pairable lines are printed; there is no `-a` yet.
