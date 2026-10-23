# MoonJQ Log CLI

These tests exercise the local `bobzhang/jqlog` module. Run them from its
module directory:

```sh
cd cmd/jqlog
moonx moonbit-community/mooncram@0.1.0 test ../../tests/cram/jqlog.md
```

Add `--target native` to test the native backend. Pipeline helpers use pinned
tools from the Mooncakes `cli` account.

## Invalid Lines

```mooncram bobzhang/jqlog
$ moonx cli/printf@0.2.1 '%s\n' 'not json' '{"end":1}' '{"end":2}' | moonx bobzhang/jqlog '.end'
1
2
```

## Terminal Errors

```mooncram bobzhang/jqlog
$ moonx cli/printf@0.2.1 '%s\n' 'not json' '1' '2' '3' | moonx bobzhang/jqlog '., if . == 2 then error("failed") else empty end'
1
2
[5]
```

```mooncram bobzhang/jqlog
$ moonx bobzhang/jqlog '.a.' 'null'
[3]
```
