# MoonJQ Log CLI

These tests exercise the local `moonbit-community/jqlog` module. Run them from its
module directory:

```sh
cd cmd/jqlog
moonx moonbit-community/mooncram@0.1.0 test ../../tests/cram/jqlog.md
```

Add `--target native` to test the native backend. Pipeline helpers use pinned
tools from the Mooncakes `cli` account.

## Invalid Lines

```mooncram moonbit-community/jqlog
$ moonx cli/printf@0.2.1 '%s\n' 'not json' '{"end":1}' '{"end":2}' | moonx moonbit-community/jqlog '.end'
1
2
```

## Terminal Errors

```mooncram moonbit-community/jqlog
$ moonx cli/printf@0.2.1 '%s\n' 'not json' '1' '2' '3' | moonx moonbit-community/jqlog '., if . == 2 then error("failed") else empty end'
1
2
[5]
```

```mooncram moonbit-community/jqlog
$ moonx moonbit-community/jqlog '.a.' 'null'
[3]
```

## Input Selection

Input can be inline text, a file, or stdin. File options can appear before or
after the query, and `--` ends option parsing.

```mooncram moonbit-community/jqlog
$ moonx moonbit-community/jqlog '.level' '{"level":"info"}'
"info"

$ moonx moonbit-community/jqlog -f fixtures/logs.ndjson '.message'
"started"
"failed"

$ moonx moonbit-community/jqlog '.level' --file=fixtures/logs.ndjson
"info"
"error"

$ moonx cli/printf@0.2.1 '%s\n' '{"end":1}' '{"end":2}' | moonx moonbit-community/jqlog '.end' -
1
2

$ moonx moonbit-community/jqlog '.' -1
-1

$ moonx moonbit-community/jqlog -- '-length' '[1,2]'
-2
```

## Argument Errors

A query is required, and file input conflicts with inline input. Argument
errors exit with status 2 before evaluating a query or reading input.

```mooncram moonbit-community/jqlog
$ moonx moonbit-community/jqlog
[2]

$ moonx moonbit-community/jqlog --file fixtures/logs.ndjson
[2]

$ moonx moonbit-community/jqlog --file
[2]

$ moonx moonbit-community/jqlog -f fixtures/logs.ndjson --file=fixtures/logs.ndjson '.'
[2]

$ moonx moonbit-community/jqlog -f fixtures/logs.ndjson '.' '{}'
[2]

$ moonx moonbit-community/jqlog '.' '{}' '{}'
[2]
```

Help and argument diagnostics come from `moonbitlang/core/argparse`.

```mooncram moonbit-community/jqlog
$ moonx moonbit-community/jqlog --help
@STDOUT
Usage: jqlog [options] <query> [input]

Run jq filters over JSON Lines input, skipping non-JSON lines.

Arguments:
  query  The jq filter to evaluate.
  input  Input text; omit or use - to read stdin.

Options:
  -h, --help         Show help information.
  -f, --file <file>  Read input text from a file.
@STDERR (empty)

$ moonx moonbit-community/jqlog --missing
@STDOUT (empty)
@STDERR
error: unexpected argument '--missing' found

Usage: jqlog [options] <query> [input]

Run jq filters over JSON Lines input, skipping non-JSON lines.

Arguments:
  query  The jq filter to evaluate.
  input  Input text; omit or use - to read stdin.

Options:
  -h, --help         Show help information.
  -f, --file <file>  Read input text from a file.
[2]
```
