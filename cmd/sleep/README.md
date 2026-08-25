# sleep for moonx

Pause for a number of seconds:

```sh
moonx bobzhang/sleep 2
moonx bobzhang/sleep 0.5
moonx bobzhang/sleep 1m 30s   # arguments are summed
```

NUMBER may be fractional; suffixes `s`, `m`, `h`, `d` scale it. With
multiple arguments, sleeps for their sum.
