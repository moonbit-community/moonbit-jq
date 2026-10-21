///|
fn Plan::start(
  self : Plan,
  id : Int32,
  input : Value,
  env : Env,
  tracking : Bool,
) -> Machine raise EvalError {
  let node = self.nodes[id]
  let span = node.span
  fn run(n : Int32) -> Machine {
    self.machine(n, input, env, tracking)
  }
  fn values(n : Int32) -> Machine {
    self.machine(n, input, env, false)
  }
  match node.code {
    Identity => Machine::one(input)
    Constant(json) => Machine::one(value(json))
    Pipe(left, right) =>
      run(left).flat_map(v => self.machine(right, v, env, tracking))
    Comma(left, right) => run(left).concat(run(right))
    Access(key) => values(key).map(k => access(input, k.json, tracking, span))
    Subscript(base, key) =>
      values(key).flat_map(k => {
        run(base).map(v => access(v, k.json, tracking, span))
      })
    Each => each(input, tracking, span)
    Slice(a, b) => {
      check_access(input, tracking, span)
      if !(input.json is (Array(_) | String(_) | Null)) {
        raise EvalError(
          Json::string(
            "Cannot slice " + @ast_internal.json_type_name(input.json),
          ),
          span,
        )
      }
      let result = slice_value(input.json, a, b)
      let segment : Json = {
        "start": a.map(n => Json::number(n.to_double())).unwrap_or(null),
        "end": b.map(n => Json::number(n.to_double())).unwrap_or(null),
      }
      Machine::one({ json: result, path: input.path.map(p => p + [segment]), })
    }
    Collect(None) => Machine::one(value(Json::array([])))
    Collect(Some(body)) =>
      values(body).collect(vs => {
        Machine::one(value(Json::array(vs.map(v => v.json))))
      })
    Object(fields) => self.object(fields, 0, Map([]), input, env, span)
    Binary(left, And, right) =>
      values(left).flat_map(a => {
        if @ast_internal.is_truthy(a.json) {
          values(right).map(b => {
            value(Json::boolean(@ast_internal.is_truthy(b.json)))
          })
        } else {
          Machine::one(value(Json::boolean(false)))
        }
      })
    Binary(left, Or, right) =>
      values(left).flat_map(a => {
        if @ast_internal.is_truthy(a.json) {
          Machine::one(value(Json::boolean(true)))
        } else {
          values(right).map(b => {
            value(Json::boolean(@ast_internal.is_truthy(b.json)))
          })
        }
      })
    Binary(left, op, right) =>
      values(right).flat_map(b => {
        values(left).map(a => {
          let json = eval_binary_op(op, a.json, b.json) catch {
            err => raise primitive_error(err, span)
          }
          value(json)
        })
      })
    If(cond, yes, no) =>
      values(cond).flat_map(c => {
        run(if @ast_internal.is_truthy(c.json) { yes } else { no })
      })
    Catch(body, handler) =>
      Machine::new(
        Catch(run(body), err => {
          match handler {
            Some(h) => self.machine(h, value(err.value()), env, tracking)
            None => Machine::empty()
          }
        }),
      )
    Alternative(left, right) =>
      Machine::new(Alternative(run(left), false, fn() { run(right) }))
    Variable(binding) =>
      match env.values.get(binding) {
        Some(Bound(v)) => Machine::one(value(v))
        _ => Machine::fail(EvalError(Json::string("Unbound variable"), span))
      }
    Bind(source, binding, body) =>
      values(source).flat_map(v => {
        self.machine(body, input, env.bind(binding, Bound(v.json)), tracking)
      })
    Scope(function, body) => {
      let functions = env.functions.copy()
      functions[function] = env
      self.machine(body, input, { values: env.values, functions, }, tracking)
    }
    Filter(binding) =>
      match env.values.get(binding) {
        Some(Closure(body, caller)) =>
          self.machine(body, input, caller, tracking)
        _ => Machine::fail(EvalError(Json::string("Unbound filter"), span))
      }
    Call(function, args) => {
      let captured = env.functions.get(function).unwrap_or(env)
      let functions = captured.functions.copy()
      functions[function] = captured
      let callee : Env = { values: captured.values, functions, }
      self.call_args(function, args, 0, input, env, callee, tracking)
    }
    Builtin(name, args) => self.builtin(name, args, input, env, tracking, span)
    Reduce(gen, binding, init, update, extract) =>
      values(init).flat_map(initial => {
        self.reduce_stream(
          values(gen),
          binding,
          initial,
          update,
          extract,
          env,
          span,
        )
      })
    Update(path, body, mode) => self.update(path, body, mode, input, env, span)
  }
}

///|
fn Plan::call_args(
  self : Plan,
  function : Int32,
  args : Array[Int32],
  index : Int32,
  input : Value,
  caller : Env,
  callee : Env,
  tracking : Bool,
) -> Machine {
  let f = self.functions[function]
  if index == args.length() {
    return self.machine(f.body, input, callee, tracking)
  }
  let param = f.params[index]
  if param.by_value {
    self
    .machine(args[index], input, caller, false)
    .flat_map(v => {
      self.call_args(
        function,
        args,
        index + 1,
        input,
        caller,
        callee.bind(param.id, Bound(v.json)),
        tracking,
      )
    })
  } else {
    // Binding closures is pure. Their bodies run only when the parameter is called.
    Machine::new(
      Defer(() => {
        self.call_args(
          function,
          args,
          index + 1,
          input,
          caller,
          callee.bind(param.id, Closure(args[index], caller)),
          tracking,
        )
      }),
    )
  }
}

///|
fn Plan::object(
  self : Plan,
  fields : Array[(Int32, Int32?)],
  index : Int32,
  object : Map[String, Json],
  input : Value,
  env : Env,
  span : @ast.Span?,
) -> Machine {
  if index == fields.length() {
    return Machine::one(value(Json::object(object)))
  }
  let (key, body) = fields[index]
  self
  .machine(key, input, env, false)
  .flat_map(k => {
    guard k.json is String(name) else {
      raise EvalError(Json::string("Object keys must be strings"), span)
    }
    let values = match body {
      Some(n) => self.machine(n, input, env, false)
      None => Machine::one(access(input, k.json, false, span))
    }
    values.flat_map(v => {
      let next = object.copy()
      next[name] = v.json
      self.object(fields, index + 1, next, input, env, span)
    })
  })
}
