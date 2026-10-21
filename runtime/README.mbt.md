# Compiler and resumable runtime

`compile(ast)` resolves names and function arities, allocates binding IDs, and
lowers interpolation into ordinary text conversion and addition. The resulting
`Plan` hides its instruction storage. Evaluation never changes the plan.
Function scopes are explicit instructions; executing a pipe does not install a
function definition. Closures capture the caller environment for filter
arguments and the definition environment for function bodies.

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

Values carry optional path provenance. Navigation extends it; computations clear
it. Path validation is enabled inside `path` and assignments, while conditions
and arguments use ordinary value semantics. There is no separate path control-flow
interpreter. UTF-16 spans on plan nodes supply runtime error locations.

The stream/frontend contract targets jq 1.7.1. Existing pure-operation limitations
remain, including the limited regular-expression implementation and stricter
base64 decoding. `leaf_paths` and the one-argument `pow` form remain compatibility
extensions. This migration does not add jq's module system or replace the regex
algorithm. The fixed semantic fixture and bounded generator avoid these documented
extensions and independent algorithms.
