# xxd for moonx

Make a hex dump, or reverse one back into bytes:

```sh
printf 'hello' | moonx bobzhang/xxd
moonx bobzhang/xxd -p data.bin            # plain continuous hex
moonx bobzhang/xxd -r dump.txt > out.bin  # reverse a dump
printf '68690a' | moonx bobzhang/xxd -r -p
```

Options: `-p` plain hex, `-r` reverse (with or without `-p`), `-c N` bytes
per line (default 16, or 30 with `-p`), `-l N` stop after N bytes.
Reverse mode ignores offsets and concatenates the hex columns in order.
