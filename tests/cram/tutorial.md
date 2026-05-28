# MoonJQ Tutorial Examples

These tests mirror the tutorial examples against a local commit-shaped fixture.

```mooncram
$ printf '%s\n' '[{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]},' '{"sha":"b2","commit":{"message":"Add cram coverage","author":{"name":"Grace Hopper"}},"author":{"login":"grace"},"parents":[{"html_url":"https://example.com/commit/a1"},{"html_url":"https://example.com/commit/root"}]}]' > commits.json
```

## Identity

```mooncram
$ "$MOONJQ_CLI" -c '.' commits.json
[{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]},{"sha":"b2","commit":{"message":"Add cram coverage","author":{"name":"Grace Hopper"}},"author":{"login":"grace"},"parents":[{"html_url":"https://example.com/commit/a1"},{"html_url":"https://example.com/commit/root"}]}]
```

## Array Indexing

```mooncram
$ "$MOONJQ_CLI" -c '.[0]' commits.json
{"sha":"a1","commit":{"message":"Fix parser precedence","author":{"name":"Ada Lovelace"}},"author":{"login":"ada"},"parents":[{"html_url":"https://example.com/commit/root"}]}
```

## Object Construction

```mooncram
$ "$MOONJQ_CLI" -c '.[0] | {message: .commit.message, name: .commit.author.name}' commits.json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
```

## Iteration

```mooncram
$ "$MOONJQ_CLI" -c '.[] | {message: .commit.message, name: .commit.author.name}' commits.json
{"message":"Fix parser precedence","name":"Ada Lovelace"}
{"message":"Add cram coverage","name":"Grace Hopper"}
```

## Collecting Results

```mooncram
$ "$MOONJQ_CLI" -c '[.[] | {message: .commit.message, name: .commit.author.name}]' commits.json
[{"message":"Fix parser precedence","name":"Ada Lovelace"},{"message":"Add cram coverage","name":"Grace Hopper"}]
```

## Nested Arrays

```mooncram
$ "$MOONJQ_CLI" -c '[.[] | {message: .commit.message, name: .commit.author.name, parents: [.parents[].html_url]}]' commits.json
[{"message":"Fix parser precedence","name":"Ada Lovelace","parents":["https://example.com/commit/root"]},{"message":"Add cram coverage","name":"Grace Hopper","parents":["https://example.com/commit/a1","https://example.com/commit/root"]}]
```
