# Syntax trees

`@parser.parse` returns a syntax tree with `Located` nodes. Locations are
half-open UTF-16 offsets into the original query, including inside interpolation.
Calls retain their names and arguments; `@runtime.compile` resolves them.
Evaluation is provided by `Query` in the root package.
