# MoonJQ Tutorial

This is a MoonJQ version of the jq tutorial. It uses a small local fixture with
the same shape as the GitHub commits API so the examples are stable and do not
depend on network access.

The examples are executable documentation. Run mooncram from the local jq
module so it builds the checked-out implementation. The `cli/cat` tool comes
from Mooncakes at a fixed version:

```bash
cd cmd/jq
moonx moonbit-community/mooncram@0.1.0 test ../../TUTORIAL.md
```

The default backend is Wasm; add `--target native` to test the native backend.
Each block uses `#cwd` to read the checked-in fixture directory.

For manual runs from the repository root:

```bash
moon run cmd/jq --target native -- -c '.[0]' tests/cram/fixtures/commits.json
```

## Sample Data

The fixture `tests/cram/fixtures/commits.json` contains two commits:

```mooncram
#cwd(tests/cram/fixtures)
$ moonx cli/cat@0.2.1 commits.json
[{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]},
{"sha":"b2","commit":{"message":"Add cram coverage","author":{"name":"Grace Hopper"}},"author":{"login":"grace"},"parents":[{"html_url":"https://example.com/commit/a1"},{"html_url":"https://example.com/commit/root"}]}]
```

## Identity

The `.` filter returns its input unchanged:

```mooncram moonbit-community/jq
#cwd(tests/cram/fixtures)
$ moonx moonbit-community/jq -c '.' commits.json
[{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]},{"sha":"b2","commit":{"message":"Add cram coverage","author":{"name":"Grace Hopper"}},"author":{"login":"grace"},"parents":[{"html_url":"https://example.com/commit/a1"},{"html_url":"https://example.com/commit/root"}]}]
```

## Array Indexing

Use `.[0]` to select the first item:

```mooncram moonbit-community/jq
#cwd(tests/cram/fixtures)
$ moonx moonbit-community/jq -c '.[0]' commits.json
{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]}
```

## Object Construction

Build a new object by naming the output fields and assigning filters to them:

```mooncram moonbit-community/jq
#cwd(tests/cram/fixtures)
$ moonx moonbit-community/jq -c '.[0] | {message: .commit.message, name: .commit.author.name}' commits.json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
```

## Iteration

The `.[]` filter emits each array element as a separate result:

```mooncram moonbit-community/jq
#cwd(tests/cram/fixtures)
$ moonx moonbit-community/jq -c '.[] | {message: .commit.message, name: .commit.author.name}' commits.json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
{"message":"Add cram coverage","name":"Grace Hopper"}
```

## Collecting Results

Wrap a stream in `[...]` to collect all emitted values into one array:

```mooncram moonbit-community/jq
#cwd(tests/cram/fixtures)
$ moonx moonbit-community/jq -c '[.[] | {message: .commit.message, name: .commit.author.name}]' commits.json
[{"message":"Fix parser precedence","name":"Ada Lovelace"},{"message":"Add cram coverage","name":"Grace Hopper"}]
```

## Nested Arrays

Use the same iteration and collection pattern inside object fields:

```mooncram moonbit-community/jq
#cwd(tests/cram/fixtures)
$ moonx moonbit-community/jq -c '[.[] | {message: .commit.message, name: .commit.author.name, parents: [.parents[].html_url]}]' commits.json
[{"message":"Fix parser precedence","name":"Ada Lovelace","parents":["https://example.com/commit/root"]},{"message":"Add cram coverage","name":"Grace Hopper","parents":["https://example.com/commit/a1","https://example.com/commit/root"]}]
```

The original jq tutorial is at <https://jqlang.org/tutorial/>.
