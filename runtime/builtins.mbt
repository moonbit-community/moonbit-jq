///|
fn Plan::arguments(
  self : Plan,
  args : Array[Int32],
  index : Int32,
  input : Value,
  env : Env,
  out : Array[Json],
  apply : (Array[Json]) -> Machine raise EvalError,
) -> Machine {
  if index < 0 {
    return Machine::new(Defer(() => apply(out)))
  }
  self
  .machine(args[index], input, env, false)
  .flat_map(v => {
    let next = out.copy()
    next[index] = v.json
    self.arguments(args, index - 1, input, env, next, apply)
  })
}

///|
fn Plan::builtin(
  self : Plan,
  name : String,
  args : Array[Int32],
  input : Value,
  env : Env,
  tracking : Bool,
  span : @ast.Span?,
) -> Machine raise EvalError {
  fn run(n : Int32) -> Machine {
    self.machine(n, input, env, tracking)
  }
  fn values(n : Int32) -> Machine {
    self.machine(n, input, env, false)
  }
  let spec = builtin_spec(name, args.length())
  match (name, args) {
    ("select", [cond]) =>
      values(cond).flat_map(c => {
        if @ast_internal.is_truthy(c.json) {
          Machine::one(input)
        } else {
          Machine::empty()
        }
      })
    ("map", [body]) =>
      each(input, false, span)
      .flat_map(v => self.machine(body, v, env, false))
      .collect(vs => Machine::one(value(Json::array(vs.map(v => v.json)))))
    ("with_entries", [body]) => {
      let entries = eval_to_entries(input.json) catch {
        err => raise primitive_error(err, span)
      }
      let entries = value(entries.next().unwrap_or(null))
      each(entries, false, span)
      .flat_map(v => self.machine(body, v, env, false))
      .collect(vs => {
        let result = eval_from_entries(Json::array(vs.map(v => v.json))) catch {
          err => raise primitive_error(err, span)
        }
        Machine::new(Values(result.map(value)))
      })
    }
    ("map_values", [body]) => {
      let paths = each({ json: input.json, path: Some([]), }, true, span)
      self.modify(paths, body, input.json, env, span)
    }
    ("sort_by" | "group_by" | "unique_by" | "min_by" | "max_by", [key]) if spec
      is Some({ consumption: CollectAll, .. }) =>
      self.order(name, key, input, env, span)
    ("first", []) =>
      Machine::one(access(input, Json::number(0), tracking, span))
    ("last", []) =>
      Machine::one(access(input, Json::number(-1), tracking, span))
    ("first", [body]) => run(body).take(1)
    ("last", [body]) => Machine::new(Last(values(body), null))
    ("limit", [count, body]) =>
      values(count).flat_map(v => {
        let n = number_arg(v.json, span).to_int()
        if n < 0 {
          run(body)
        } else {
          run(body).take(n)
        }
      })
    ("nth", [count, body]) =>
      values(count).flat_map(v => {
        let n = number_arg(v.json, span).to_int()
        if n < 0 {
          raise EvalError(
            Json::string("nth doesn't support negative indices"),
            span,
          )
        }
        let i = Ref(0)
        run(body)
        .take(n + 1)
        .flat_map(v => {
          i.val += 1
          if i.val == n + 1 {
            Machine::one(v)
          } else {
            Machine::empty()
          }
        })
      })
    ("combinations", []) => combinations(input.json, span)
    ("repeat", [body]) => Machine::new(Repeat(fn() { run(body) }))
    ("path", [body]) =>
      self
      .machine(body, { json: input.json, path: Some([]), }, env, true)
      .map(v => path_result(v, span))
    ("any" | "all", _) if spec is Some({ consumption: ShortCircuit, .. }) => {
      let generator = if args.length() == 2 {
        values(args[0])
      } else {
        each(input, false, span)
      }
      let stream = if args.length() == 0 {
        generator
      } else {
        let cond = args[args.length() - 1]
        generator.flat_map(v => self.machine(cond, v, env, false))
      }
      let wanted = name == "any"
      stream
      .flat_map(v => {
        if @ast_internal.is_truthy(v.json) == wanted {
          Machine::one(v)
        } else {
          Machine::empty()
        }
      })
      .take(1)
      .collect(vs => {
        Machine::one(
          value(Json::boolean(if vs.is_empty() { !wanted } else { wanted })),
        )
      })
    }
    ("recurse", _) => self.recurse(args, input, env, tracking, span)
    ("paths" | "leaf_paths", _) => {
      let root : Value = { json: input.json, path: Some([]), }
      let stream = self.recurse([], root, env, false, span)
      let filtered = if args is [filter] {
        stream.flat_map(v => {
          self
          .machine(filter, v, env, false)
          .flat_map(c => {
            if @ast_internal.is_truthy(c.json) {
              Machine::one(v)
            } else {
              Machine::empty()
            }
          })
        })
      } else if name == "leaf_paths" {
        stream.flat_map(v => {
          if v.json is (Array(_) | Object(_)) {
            Machine::empty()
          } else {
            Machine::one(v)
          }
        })
      } else {
        stream
      }
      filtered.flat_map(v => {
        if v.path is Some(p) && !p.is_empty() {
          Machine::one(path_result(v, span))
        } else {
          Machine::empty()
        }
      })
    }
    ("until" | "while", [cond, update]) =>
      self.loop_filter(name, cond, update, input, env, tracking)
    ("walk", [body]) => self.walk(body, input, env, span)
    _ => {
      if name.has_prefix("@") {
        let results = eval_format(name[1:].to_owned(), input.json) catch {
          err => raise primitive_error(err, span)
        }
        return Machine::new(Values(results.map(value)))
      }
      let spec = spec.unwrap()
      match (spec.mode, spec.consumption) {
        (Values, EachResult) | (Mixed, FirstResult) =>
          self.arguments(
            args,
            args.length() - 1,
            input,
            env,
            Array::make(args.length(), null),
            params => {
              if name == "getpath" {
                guard params[0] is Array(path) else {
                  raise EvalError(
                    Json::string("Path must be specified as an array"),
                    span,
                  )
                }
                let mut result = input
                for key in path {
                  result = access(result, key, tracking, span)
                }
                return Machine::one(result)
              }
              if name == "nth" {
                return Machine::one(access(input, params[0], tracking, span))
              }
              if name == "error" {
                let error = if params.is_empty() {
                  input.json
                } else {
                  params[0]
                }
                return if error is Null {
                  Machine::empty()
                } else {
                  Machine::fail(EvalError(error, span))
                }
              }
              if name == "range" {
                return range_values(params, span)
              }
              let results = pure_builtin(name, input.json, params) catch {
                err => raise primitive_error(err, span)
              }
              Machine::new(Values(results.map(value)))
            },
          )
        _ => raise EvalError(Json::string("Missing consumer for " + name), span)
      }
    }
  }
}

///|
fn number_arg(json : Json, span : @ast.Span?) -> Double raise EvalError {
  match json {
    Number(n, ..) => n
    _ => raise EvalError(Json::string("Expected number"), span)
  }
}

///|
fn range_values(
  args : Array[Json],
  span : @ast.Span?,
) -> Machine raise EvalError {
  let start = if args.length() == 1 { 0.0 } else { number_arg(args[0], span) }
  let end = number_arg(args[if args.length() == 1 { 0 } else { 1 }], span)
  let step = if args.length() == 3 { number_arg(args[2], span) } else { 1.0 }
  let cursor = Ref(start)
  Machine::new(
    Values(
      Iter::new(fn() {
        let n = cursor.val
        if (step > 0 && n < end) || (step < 0 && n > end) {
          cursor.val += step
          Some(value(Json::number(n)))
        } else {
          None
        }
      }),
    ),
  )
}
