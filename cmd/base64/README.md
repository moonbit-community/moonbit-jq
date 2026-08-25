# base64 for moonx

Base64 encode or decode a file or stdin:

```sh
printf 'hello' | moonx bobzhang/base64
moonx bobzhang/base64 -d encoded.txt
moonx bobzhang/base64 -w 0 big.bin   # no line wrapping
```

Options: `-d` decode (whitespace in the input is ignored), `-w N` wrap
encoded output after N characters (default 76, `0` disables). Standard
alphabet with `=` padding.
