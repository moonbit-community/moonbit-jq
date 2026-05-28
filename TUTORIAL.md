# MoonJQ Tutorial

This is a MoonJQ version of the jq tutorial. It uses a small local fixture with
the same shape as the GitHub commits API so the examples are stable and do not
depend on network access.

The examples are executable documentation. The cram runner builds the native CLI
and exposes it as `MOONJQ_CLI`:

```bash
moon run --target native scripts/check_cram_cli.mbtx
```

For manual runs, build the CLI and set the same variable:

```bash
moon build --target native --release cmd/jq
MOONJQ_CLI="$PWD/_build/native/release/build/cmd/jq/jq.exe"
```

## Sample Data

Create `commits.json`:

```mooncram
$ printf '%s\n' '[{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]},' '{"sha":"b2","commit":{"message":"Add cram coverage","author":{"name":"Grace Hopper"}},"author":{"login":"grace"},"parents":[{"html_url":"https://example.com/commit/a1"},{"html_url":"https://example.com/commit/root"}]}]' > commits.json
```

## Identity

The `.` filter returns its input unchanged:

```mooncram
$ "$MOONJQ_CLI" -c '.' commits.json
[{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]},{"sha":"b2","commit":{"message":"Add cram coverage","author":{"name":"Grace Hopper"}},"author":{"login":"grace"},"parents":[{"html_url":"https://example.com/commit/a1"},{"html_url":"https://example.com/commit/root"}]}]
```

## Array Indexing

Use `.[0]` to select the first item:

```mooncram
$ "$MOONJQ_CLI" -c '.[0]' commits.json
{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]}
```

## Object Construction

Build a new object by naming the output fields and assigning filters to them:

```mooncram
$ "$MOONJQ_CLI" -c '.[0] | {message: .commit.message, name: .commit.author.name}' commits.json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
```

## Iteration

The `.[]` filter emits each array element as a separate result:

```mooncram
$ "$MOONJQ_CLI" -c '.[] | {message: .commit.message, name: .commit.author.name}' commits.json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
{"message":"Add cram coverage","name":"Grace Hopper"}
```

## Collecting Results

Wrap a stream in `[...]` to collect all emitted values into one array:

```mooncram
$ "$MOONJQ_CLI" -c '[.[] | {message: .commit.message, name: .commit.author.name}]' commits.json
[{"message":"Fix parser precedence","name":"Ada Lovelace"},{"message":"Add cram coverage","name":"Grace Hopper"}]
```

## Nested Arrays

Use the same iteration and collection pattern inside object fields:

```mooncram
$ "$MOONJQ_CLI" -c '[.[] | {message: .commit.message, name: .commit.author.name, parents: [.parents[].html_url]}]' commits.json
[{"message":"Fix parser precedence","name":"Ada Lovelace","parents":["https://example.com/commit/root"]},{"message":"Add cram coverage","name":"Grace Hopper","parents":["https://example.com/commit/a1","https://example.com/commit/root"]}]
```

The original jq tutorial is at <https://jqlang.org/tutorial/>.
