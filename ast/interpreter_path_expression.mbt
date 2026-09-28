///|
/// Error message for a filter that is not a path expression.
let invalid_path_expression : String = "Invalid path expression"

///|
/// Evaluate `expr` as a jq path expression against `input`.
///
/// Returns, in output order, each path `expr` refers to together with the
/// value found there. Only filters that navigate the input are path
/// expressions (`.`, `..`, `.k`, `.[i]`, `.[]`, pipes, commas, `select`,
/// `if`, `//`, `?`, `empty`, `first`, `last`, `first(f)`, `last(f)`,
/// `getpath`, `... as $x | ...` and user-defined functions built from
/// them); anything else raises "Invalid path expression", as in jq.
fn path_values(
  expr : Expr,
  input : Json,
  env : Env,
) -> Array[(Array[Json], Json)] raise InterpreterError {
  match expr {
    Identity => [([], input)]
    Recurse => recurse_path_values(input)
    Key(key) => {
      let value = match input {
        Object(obj) => obj.get(key).unwrap_or(null)
        _ => null
      }
      [([Json::string(key)], value)]
    }
    Index([]) =>
      match input {
        Array(arr) => arr.mapi((i, v) => ([Json::number(i.to_double())], v))
        Object(obj) =>
          obj.iter().map(kv => ([Json::string(kv.0)], kv.1)).collect()
        _ => []
      }
    Index(indices) => {
      let values = eval_index_access(indices, input).collect()
      indices.mapi((i, idx) => ([Json::number(idx.to_double())], values[i]))
    }
    // jq: `def first: .[0]; def last: .[-1];` -- the path exists even
    // when the array is empty.
    First =>
      match input {
        Array(arr) => [([Json::number(0.0)], arr.get(0).unwrap_or(null))]
        Null => [([Json::number(0.0)], null)]
        _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
      }
    Last =>
      match input {
        Array(arr) => [([Json::number(-1.0)], arr.last().unwrap_or(null))]
        Null => [([Json::number(-1.0)], null)]
        _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
      }
    FirstGen(gen) =>
      match path_values(gen, input, env) {
        [first, ..] => [first]
        [] => []
      }
    LastGen(gen) =>
      match path_values(gen, input, env) {
        [.., last] => [last]
        [] => []
      }
    Empty => []
    Pipe(FunctionDef(name, params, body), right) =>
      path_values(right, input, env.set_function(name, body, params))
    Pipe(left, right) => {
      let out : Array[(Array[Json], Json)] = []
      for pair in path_values(left, input, env) {
        let (prefix, value) = pair
        for inner in path_values(right, value, env) {
          out.push((prefix + inner.0, inner.1))
        }
      }
      out
    }
    Comma(left, right) =>
      path_values(left, input, env) + path_values(right, input, env)
    // `?` suppresses errors raised while evaluating, but not the error for
    // a result that is not a path (jq reports that one after the try).
    Optional(inner) =>
      path_values(inner, input, env) catch {
        InvalidOperation(msg) if msg == invalid_path_expression =>
          raise InvalidOperation(msg)
        _ => []
      }
    // Like jq, act once per output of the condition (none for `empty`).
    Select(cond) => {
      let out : Array[(Array[Json], Json)] = []
      for c in eval_with_env(cond, input, env).collect() {
        if @ast_internal.is_truthy(c) {
          out.push(([], input))
        }
      }
      out
    }
    IfThenElse(cond, then_expr, else_expr) => {
      let out : Array[(Array[Json], Json)] = []
      for c in eval_with_env(cond, input, env).collect() {
        let branch = if @ast_internal.is_truthy(c) {
          then_expr
        } else {
          else_expr
        }
        out.append(path_values(branch, input, env))
      }
      out
    }
    Alternative(left, right) => {
      // `//` suppresses errors from its left side (jq's FORK_OPT), but a
      // non-path result is still an error, as in jq 1.7:
      // `{"a":1} | (length // .a) = 2` raises "Invalid path expression".
      let lefts = path_values(left, input, env) catch {
        InvalidOperation(msg) if msg == invalid_path_expression =>
          raise InvalidOperation(msg)
        _ => []
      }
      let truthy = lefts.filter(pair => @ast_internal.is_truthy(pair.1))
      if truthy.is_empty() {
        path_values(right, input, env)
      } else {
        truthy
      }
    }
    GetPath(path_expr) => {
      let out : Array[(Array[Json], Json)] = []
      for path in eval_with_env(path_expr, input, env) {
        guard path is Array(segments) else {
          raise InvalidOperation("Path must be specified as an array")
        }
        out.push(
          (segments.copy(), get_at_path(input, segments).unwrap_or(null)),
        )
      }
      out
    }
    As(source, var_name, body) => {
      let out : Array[(Array[Json], Json)] = []
      for value in eval_with_env(source, input, env).collect() {
        out.append(path_values(body, input, env.set(var_name, value)))
      }
      out
    }
    FunctionCall(name, args) =>
      match env.get_function(name) {
        Some((body, [])) => path_values(body, input, env)
        Some((body, params)) => {
          if args.length() != params.length() {
            raise EvalError(
              "Function \{name} expects \{params.length()} arguments, got \{args.length()}",
            )
          }
          let arg_values = args.map(arg => {
            match eval_with_env(arg, input, env).collect() {
              [] => null
              [first, ..] => first
            }
          })
          path_values(body, input, bind_params(env, params, arg_values))
        }
        None => raise EvalError("Undefined function: \{name}")
      }
    _ => raise InvalidOperation(invalid_path_expression)
  }
}

///|
/// Paths of `..`: the input itself, then every descendant in pre-order.
fn recurse_path_values(input : Json) -> Array[(Array[Json], Json)] {
  let out : Array[(Array[Json], Json)] = []
  fn go(prefix : Array[Json], value : Json) -> Unit {
    out.push((prefix, value))
    match value {
      Array(arr) =>
        for i, v in arr {
          go(prefix + [Json::number(i.to_double())], v)
        }
      Object(obj) =>
        for k, v in obj {
          go(prefix + [Json::string(k)], v)
        }
      _ => ()
    }
  }

  go([], input)
  out
}

///|
/// Evaluate Path: `path(f)` yields each path `f` refers to.
fn eval_path(
  expr : Expr,
  input : Json,
  env : Env,
) -> Iter[Json] raise InterpreterError {
  path_values(expr, input, env).map(pair => Json::array(pair.0)).iter()
}
