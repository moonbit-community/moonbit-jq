# MoonJQ Tutorial

This is a MoonJQ version of the jq tutorial. It uses a small local fixture with
the same shape as the GitHub commits API so the examples are stable and do not
depend on network access.

For the commands below, either run through Moon:

```bash
moon run cmd/jq --target native --
```

or build the native CLI once and use the binary directly:

```bash
moon build --target native --release cmd/jq
MOONJQ=_build/native/release/build/cmd/jq/jq.exe
```

## Sample Data

Save this as `commits.json`:

```json
[
  {
    "sha": "a1",
    "commit": {
      "message": "Fix parser precedence",
      "author": { "name": "Ada Lovelace" }
    },
    "author": { "login": "ada" },
    "parents": [
      { "html_url": "https://example.com/commit/root" }
    ]
  },
  {
    "sha": "b2",
    "commit": {
      "message": "Add cram coverage",
      "author": { "name": "Grace Hopper" }
    },
    "author": { "login": "grace" },
    "parents": [
      { "html_url": "https://example.com/commit/a1" },
      { "html_url": "https://example.com/commit/root" }
    ]
  }
]
```

## Identity

The `.` filter returns its input unchanged:

```bash
$MOONJQ '.' commits.json
```

## Array Indexing

Use `.[0]` to select the first item:

```bash
$MOONJQ '.[0]' commits.json
```

Compact output is often easier to scan in examples:

```bash
$MOONJQ -c '.[0]' commits.json
```

```json
{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]}
```

## Object Construction

Build a new object by naming the output fields and assigning filters to them:

```bash
$MOONJQ -c '.[0] | {message: .commit.message, name: .commit.author.name}' commits.json
```

```json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
```

## Iteration

The `.[]` filter emits each array element as a separate result:

```bash
$MOONJQ -c '.[] | {message: .commit.message, name: .commit.author.name}' commits.json
```

```json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
{"message":"Add cram coverage","name":"Grace Hopper"}
```

## Collecting Results

Wrap a stream in `[...]` to collect all emitted values into one array:

```bash
$MOONJQ -c '[.[] | {message: .commit.message, name: .commit.author.name}]' commits.json
```

```json
[{"message":"Fix parser precedence","name":"Ada Lovelace"},{"message":"Add cram coverage","name":"Grace Hopper"}]
```

## Nested Arrays

You can use the same iteration and collection pattern inside object fields:

```bash
$MOONJQ -c '[.[] | {message: .commit.message, name: .commit.author.name, parents: [.parents[].html_url]}]' commits.json
```

```json
[{"message":"Fix parser precedence","name":"Ada Lovelace","parents":["https://example.com/commit/root"]},{"message":"Add cram coverage","name":"Grace Hopper","parents":["https://example.com/commit/a1","https://example.com/commit/root"]}]
```

The original jq tutorial is at <https://jqlang.org/tutorial/>.
