# MoonBit Coreutils CLIs

These tests exercise the coreutils-style workspace commands. `moon cram`
builds the workspace first and puts the built CLI binaries in `PATH`, so the
tests call each `<tool>.exe` directly. Commands whose output has no trailing
newline append `echo` so every expected block ends with a newline.

## wc

```mooncram
$ printf 'one two\nthree\n' | wc.exe
2 3 14
```

```mooncram
$ printf 'one two\nthree\n' | wc.exe -l
2
```

## head And tail

```mooncram
$ printf '1\n2\n3\n4\n' | head.exe -n 2
1
2
```

```mooncram
$ printf '1\n2\n3\n4\n' | tail.exe -n 2
3
4
```

```mooncram
$ printf '1\n2\n3\n4\n' | tail.exe -n +3
3
4
```

```mooncram
$ printf 'abcdef\n' | head.exe -c 3 && echo
abc
```

## nl

```mooncram
$ printf 'alpha\nbeta\n' | nl.exe -w 3 -s ' '
  1 alpha
  2 beta
```

## uniq

```mooncram
$ printf 'a\na\nb\na\n' | uniq.exe -c
      2 a
      1 b
      1 a
```

```mooncram
$ printf 'a\na\nb\na\n' | uniq.exe -d
a
```

## cut

```mooncram
$ printf 'x,y,z\n1,2,3\n' | cut.exe -d, -f1,3
x,z
1,3
```

```mooncram
$ printf 'alpha beta\nnodelim\n' | cut.exe -d' ' -f2 -s
beta
```

## paste

```mooncram
$ printf '1\n2\n' > nums.txt && printf 'a\nb\n' > letters.txt && paste.exe -d, nums.txt letters.txt
1,a
2,b
```

```mooncram
$ printf '1\n2\n' > nums.txt && paste.exe -s -d, nums.txt
1,2
```

## comm

```mooncram
$ printf 'a\nb\nc\n' > left.txt && printf 'b\nc\nd\n' > right.txt && comm.exe -23 left.txt right.txt
a
```

```mooncram
$ printf 'a\nb\nc\n' > left.txt && printf 'b\nc\nd\n' > right.txt && comm.exe -12 left.txt right.txt
b
c
```

## join

```mooncram
$ printf '1 alice\n2 bob\n' > people.txt && printf '1 red\n2 blue\n' > colors.txt && join.exe people.txt colors.txt
1 alice red
2 bob blue
```

```mooncram
$ printf '1,alice\n2,bob\n' > people.csv && printf '1,red\n' > colors.csv && join.exe -t, people.csv colors.csv
1,alice,red
```

## sort

```mooncram
$ printf '10\n2\n1\n' | sort.exe -n
1
2
10
```

```mooncram
$ printf 'b\na\nc\na\n' | sort.exe -u -r
c
b
a
```

```mooncram
$ printf 'b 2\na 1\nc 3\n' | sort.exe -k 2
a 1
b 2
c 3
```

## tr

```mooncram
$ printf 'hello world' | tr.exe 'a-z' 'A-Z' && echo
HELLO WORLD
```

```mooncram
$ printf 'aabbcc' | tr.exe -d 'b' && echo
aacc
```

```mooncram
$ printf 'aaabbb' | tr.exe -s 'ab' && echo
ab
```

```mooncram
$ printf 'hello world' | tr.exe '[:lower:]' '[:upper:]' && echo
HELLO WORLD
```

## base64

```mooncram
$ printf 'hello world' | base64.exe
aGVsbG8gd29ybGQ=
```

```mooncram
$ printf 'aGVsbG8gd29ybGQ=' | base64.exe -d && echo
hello world
```

## xxd

```mooncram
$ printf 'hello moonbit!' | xxd.exe
00000000: 6865 6c6c 6f20 6d6f 6f6e 6269 7421       hello moonbit!
```

```mooncram
$ printf 'hi\n' | xxd.exe -p
68690a
```

```mooncram
$ printf '68690a' | xxd.exe -r -p
hi
```

```mooncram
$ printf 'hello moonbit!' | xxd.exe | xxd.exe -r && echo
hello moonbit!
```

## Review Regressions

```mooncram
$ printf 'abcdef\n' | cut.exe -c -3
abc
```

```mooncram
$ printf 'héllo\n' | wc.exe -m
6
```

```mooncram
$ printf 'hello' | xxd.exe -l 0
```

## printf

```mooncram
$ printf.exe '%s=%d\n' answer 42
answer=42
```

```mooncram
$ printf.exe '%5d|%-5d|%05d|%+d\n' 42 42 42 7
   42|42   |00042|+7
```

```mooncram
$ printf.exe '%x %X %#o %.3d\n' 255 255 8 5
ff FF 010 005
```

```mooncram
$ printf.exe '%s\n' one two three
one
two
three
```

```mooncram
$ printf.exe '%.2f %e %g\n' 3.14159 12345.678 0.0001
3.14 1.234568e+04 0.0001
```

```mooncram
$ printf.exe '%b|\n' 'a\tb'
a	b|
```

```mooncram
$ printf.exe 'x\x41\1012\n'
xAA2
```

```mooncram
$ printf.exe '%d\n' 0x1f 010 "'A"
31
8
65
```
