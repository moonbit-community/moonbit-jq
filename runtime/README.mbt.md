# Compiler and resumable runtime

`compile(ast)` resolves names and function arities, allocates binding IDs, and
lowers syntax into an immutable `Plan` with private instructions. Evaluation
never changes the plan. Functions and filter parameters share a callable symbol
table keyed by name and arity. Each lexical scope copies the table, so a later
local definition shadows a parameter of the same arity while earlier definitions
retain the bindings visible at their definition. Function scopes are explicit
instructions; executing a pipe does not install a function definition.

Every user-function argument is a filter closure capturing the caller's
environment. Function bodies capture their definition environment. A parameter
declared as `$x` allocates both a filter binding `x` and a separate variable
binding `$x`; the compiler inserts `x as $x` at function entry, in parameter
declaration order. The variable retains the selected value, while calling `x`
runs the original argument again on the current input. There is no separate
runtime argument evaluator for value parameters.

The same `Bind` instruction expands value arguments to builtins before a
primitive receives their bound JSON values. The builtin registry declares
evaluation order: `range/1..3` evaluates arguments from left to right; other
value builtins retain their right-to-left order. Each binding runs on the
original input, preserving Cartesian-product order, empty streams, and errors.
Filter and mixed arguments retain their explicit consumer rules. Interpolation
lowers to ordinary text conversion and addition. Ranges generate values on demand.

`eval(plan, input)` creates an independent suspended machine and exposes
`Iter[Result[Json, EvalError]]`. `eval_all` consumes that stream and raises its
first error. No old evaluator is called by the machine.

The machine has explicit run, branch, pull, catch, collection, limit, last-value,
and repeat frames. A trampoline with a wait stack advances nested streams without
recursive calls to `next`. Errors terminate the failing stream; catch frames
handle only the stream they own. Downstream errors therefore cannot be swallowed
by an upstream `try` or `?`.

| Consumer | Rule |
| --- | --- |
| Pipe, comma, select, object fields | Advance one branch or output at a time |
| `and`, `or`, `any`, `all` | Stop branches according to boolean semantics |
| `first`, `limit`, `nth` | Stop at the specified output count |
| `last` | Consume all results while retaining one value |
| Arrays, `map`, sort/group keys | Explicitly collect the required results |
| `reduce` | Consume each update stream; retain its last accumulator |
| `foreach` | Retain each accumulator and run extraction for every update |
| `|=` | Take the first update; delete on an empty update |

Only ordinary assignment and update assignment remain in the execution plan.
For `op=`, compilation binds each right-hand result on the original input before
updating the selected paths with `. op $saved`. `//=` uses `. // $saved` as its
update. Consequently even a truthy target consumes every right-hand result, an
empty right-hand stream emits nothing, and an error after a result preserves the
preceding output. Each result starts a separate update of the original input.
The updater always takes the first result per path and queues empty updates for
deletion. This lowering follows the
[jq 1.7.1 assignment compiler](https://github.com/jqlang/jq/blob/jq-1.7.1/src/parser.y).

Field, index, iteration, and slice syntax lower to a common navigation
instruction. Quoted fields and bracket subscripts use the same AST form: evaluate
the key on the original input, then run the base expression for each key. Values
carry optional path provenance. Navigation extends it with the original JSON
segment; computations clear it. Path validation is enabled inside `path` and
assignments, while conditions and arguments use ordinary value semantics.
There is no separate path control-flow interpreter. UTF-16 spans on plan nodes
supply runtime error locations, including errors in lowered expressions.

A private field/index/slice segment model supplies shared reads and writes.
Bounds and negative indices are normalized at the container being visited; the
raw bounds remain available to `path()`. Slice writes read the selected region,
recursively update the remaining path, and splice the array replacement back.
Writing through a slice of a missing or null value creates an array. A slice
replacement must be an array.

Batch deletion sorts raw paths with jq's JSON ordering and groups equal prefixes.
A whole-prefix deletion covers its descendants. Other groups recursively edit
their selected child and write it back, including slice reconstruction. After
these child edits, sibling indices and slices are deleted together, normalizing
them against the resulting container. Thus overlapping slice groups may change
the positions addressed by later groups, as in
[jq 1.7.1's path deletion](https://github.com/jqlang/jq/blob/jq-1.7.1/src/jv_aux.c).

`contains` and `inside` share a containment entry point which checks compatible
top-level jq kinds, distinguishing `true` from `false`. Recursive matching only
returns a boolean: a nested type mismatch is a non-match, and arrays continue
searching their remaining candidates.

The stream/frontend contract targets jq 1.7.1. Existing pure-operation limitations
remain, including the limited regular-expression implementation and stricter
base64 decoding. `leaf_paths` and the one-argument `pow` form remain compatibility
extensions. This migration does not add jq's module system or replace the regex
algorithm. The fixed semantic fixture and bounded generator avoid these documented
extensions and independent algorithms.
