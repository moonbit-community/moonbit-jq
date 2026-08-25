# printf for moonx

Format and print data like printf(1):

```sh
moonx bobzhang/printf '%s=%d\n' answer 42
moonx bobzhang/printf '%5.2f|%-8x|%o\n' 3.14159 255 8
moonx bobzhang/printf '%s\n' one two three   # format reused per argument
moonx bobzhang/printf '\x41é\n'
```

Supported: the escapes `\a \b \e \f \n \r \t \v \\ \" \' \NNN \0NNN \xHH
\uHHHH \UHHHHHHHH \c` (stop output); the conversions `%s %c %b %d %i %u %o
%x %X %f %e %E %g %G %%` with flags `-+ 0#`, field width, and precision
(width and precision accept `*`). `%b` interprets escapes in its argument.
Numeric arguments accept decimal, `0x` hex, leading-`0` octal, and `'C` for
a character code. The format is reused until all arguments are consumed.

Float conversions use the exact decimal expansion of the double with
round-half-even, matching GNU printf digit for digit. Use `--` before a
FORMAT that starts with `-`.
