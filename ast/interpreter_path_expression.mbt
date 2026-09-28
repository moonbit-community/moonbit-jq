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
/// them). Any other result raises "Invalid path expression", as in jq.
fn path_values(
  expr : Expr,
  input : Json,
  env : Env,
) -> Array[(Array[Json], Json)] raise InterpreterError {
  let out : Array[(Array[Json], Json)] = []
  path_each(expr, input, env, entry => {
    match entry {
      (Some(path), value) => out.push((path, value))
      (None, _) => raise InvalidOperation(invalid_path_expression)
    }
    true
  })
  |> ignore
  out
}

///|
/// Like `path_values`, but keeps results that are not paths as
/// `(None, value)` instead of raising. jq only rejects such a result when
/// it reaches the end of the path expression, so it may still be dropped
/// on the way (by `//`, `select`, `empty`, ...).
fn path_entries(
  expr : Expr,
  input : Json,
  env : Env,
) -> Array[(Array[Json]?, Json)] raise InterpreterError {
  let out : Array[(Array[Json]?, Json)] = []
  path_each(expr, input, env, entry => {
    out.push(entry)
    true
  })
  |> ignore
  out
}

///|
/// Streaming core of `path_values`: calls `emit` for each (path, value) in
/// output order and stops as soon as `emit` returns false, so that
/// `first(f)` does not evaluate `f` past its first output. Returns false
/// when evaluation was stopped. A result that is not a path is emitted
/// with a `None` path.
fn path_each(
  expr : Expr,
  input : Json,
  env : Env,
  emit : ((Array[Json]?, Json)) -> Bool raise InterpreterError,
) -> Bool raise InterpreterError {
  match expr {
    Identity => emit((Some([]), input))
    Recurse => {
      for pair in recurse_path_values(input) {
        if !emit((Some(pair.0), pair.1)) {
          return false
        }
      }
      true
    }
    Key(key) => {
      let value = match input {
        Object(obj) => obj.get(key).unwrap_or(null)
        _ => null
      }
      emit((Some([Json::string(key)]), value))
    }
    Index([]) => {
      let pairs : Array[(Array[Json], Json)] = match input {
        Array(arr) => arr.mapi((i, v) => ([Json::number(i.to_double())], v))
        Object(obj) =>
          obj.iter().map(kv => ([Json::string(kv.0)], kv.1)).collect()
        _ => []
      }
      for pair in pairs {
        if !emit((Some(pair.0), pair.1)) {
          return false
        }
      }
      true
    }
    Index(indices) => {
      let values = eval_index_access(indices, input).collect()
      for i, idx in indices {
        if !emit((Some([Json::number(idx.to_double())]), values[i])) {
          return false
        }
      }
      true
    }
    // jq: `def first: .[0]; def last: .[-1];` -- the path exists even
    // when the array is empty.
    First =>
      match input {
        Array(arr) =>
          emit((Some([Json::number(0.0)]), arr.get(0).unwrap_or(null)))
        Null => emit((Some([Json::number(0.0)]), null))
        _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
      }
    Last =>
      match input {
        Array(arr) =>
          emit((Some([Json::number(-1.0)]), arr.last().unwrap_or(null)))
        Null => emit((Some([Json::number(-1.0)]), null))
        _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
      }
    // Stop `gen` after its first output, as jq's `first(f)` does.
    FirstGen(gen) => {
      let mut found : (Array[Json]?, Json)? = None
      path_each(gen, input, env, pair => {
        found = Some(pair)
        false
      })
      |> ignore
      match found {
        Some(pair) => emit(pair)
        None => true
      }
    }
    LastGen(gen) =>
      match path_entries(gen, input, env) {
        [.., last] => emit(last)
        [] => true
      }
    Empty => true
    Pipe(FunctionDef(name, params, body), right) =>
      path_each(right, input, env.set_function(name, body, params), emit)
    Pipe(left, right) =>
      path_each(left, input, env, pair => {
        let (prefix, value) = pair
        path_each(right, value, env, inner => {
          let path = match (prefix, inner.0) {
            (Some(p), Some(q)) => Some(p + q)
            // Navigating into a value that is not a path is an error
            // (jq: "Invalid path expression near attempt to access ...");
            // passing it through unchanged keeps it a non-path result.
            (None, Some([])) | (_, None) => None
            (None, Some(_)) => raise InvalidOperation(invalid_path_expression)
          }
          emit((path, inner.1))
        })
      })
    Comma(left, right) =>
      path_each(left, input, env, emit) && path_each(right, input, env, emit)
    // `?` suppresses errors raised while evaluating its body (the body is
    // evaluated first, so errors from `emit` are not caught). A non-path
    // result is not an error here; it is rejected at the end.
    Optional(inner) => {
      let entries = path_entries(inner, input, env) catch { _ => [] }
      for entry in entries {
        if !emit(entry) {
          return false
        }
      }
      true
    }
    // Like jq, act once per output of the condition (none for `empty`).
    Select(cond) => {
      for c in eval_with_env(cond, input, env).collect() {
        if @ast_internal.is_truthy(c) && !emit((Some([]), input)) {
          return false
        }
      }
      true
    }
    IfThenElse(cond, then_expr, else_expr) => {
      for c in eval_with_env(cond, input, env).collect() {
        let branch = if @ast_internal.is_truthy(c) {
          then_expr
        } else {
          else_expr
        }
        if !path_each(branch, input, env, emit) {
          return false
        }
      }
      true
    }
    // As in jq 1.7, `//` only filters out false/null results: those may be
    // non-path values (`path(null // .a)` is ["a"]), while a truthy
    // non-path result is still rejected at the end. Errors propagate.
    Alternative(left, right) => {
      let truthy = path_entries(left, input, env).filter(entry => {
        @ast_internal.is_truthy(entry.1)
      })
      if truthy.is_empty() {
        path_each(right, input, env, emit)
      } else {
        for entry in truthy {
          if !emit(entry) {
            return false
          }
        }
        true
      }
    }
    GetPath(path_expr) => {
      for path in eval_with_env(path_expr, input, env).collect() {
        guard path is Array(segments) else {
          raise InvalidOperation("Path must be specified as an array")
        }
        if !emit(
            (
              Some(segments.copy()),
              get_at_path(input, segments).unwrap_or(null),
            ),
          ) {
          return false
        }
      }
      true
    }
    As(source, var_name, body) => {
      for value in eval_with_env(source, input, env).collect() {
        if !path_each(body, input, env.set(var_name, value), emit) {
          return false
        }
      }
      true
    }
    FunctionCall(name, args) =>
      match env.get_function(name) {
        Some((body, [])) => path_each(body, input, env, emit)
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
          path_each(body, input, bind_params(env, params, arg_values), emit)
        }
        None => raise EvalError("Undefined function: \{name}")
      }
    // Any other filter produces values that are not paths.
    _ => {
      for value in eval_with_env(expr, input, env).collect() {
        if !emit((None, value)) {
          return false
        }
      }
      true
    }
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
