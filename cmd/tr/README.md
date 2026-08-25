# tr for moonx

Translate, squeeze, or delete bytes read from stdin:

```sh
printf 'hello' | moonx bobzhang/tr 'a-z' 'A-Z'
printf 'a  b' | moonx bobzhang/tr -s ' '
moonx bobzhang/tr -d '\n' < file.txt
```

Options: `-d` delete SET1 bytes, `-s` squeeze repeats, `-c` complement
SET1. Sets support escapes (`\n`, `\t`, ...), byte ranges (`a-z`), and the
classes `[:lower:]`, `[:upper:]`, `[:digit:]`, `[:alpha:]`, `[:alnum:]`,
`[:space:]`, `[:xdigit:]`. Operates on bytes; set characters must be
Latin-1.
