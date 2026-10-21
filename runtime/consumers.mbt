///|
fn Plan::reduce_stream(
  self : Plan,
  generator : Machine,
  binding : Int32,
  initial : Value,
  update : Int32,
  extract : Int32?,
  env : Env,
  _span : @ast.Span?,
) -> Machine {
  let accumulator = Ref(initial.json)
  let stream = generator.flat_map(item => {
    let scope = env.bind(binding, Bound(item.json))
    let old = accumulator.val
    accumulator.val = null
    let updates = self
      .machine(update, value(old), scope, false)
      .map(v => {
        accumulator.val = v.json
        v
      })
    match extract {
      Some(body) =>
        updates.flat_map(v => self.machine(body, value(v.json), scope, false))
      None => updates.flat_map(_ => Machine::empty())
    }
  })
  match extract {
    Some(_) => stream
    None => stream.collect(_ => Machine::one(value(accumulator.val)))
  }
}

///|
fn Plan::order(
  self : Plan,
  name : String,
  key : Int32,
  input : Value,
  env : Env,
  span : @ast.Span?,
) -> Machine raise EvalError {
  guard input.json is Array(items) else {
    raise EvalError(Json::string("Expected array"), span)
  }
  let keyed : Array[(Json, Json)] = []
  let source = Machine::new(Values(items.iter().map(value)))
  source
  .flat_map(v => {
    self
    .machine(key, v, env, false)
    .collect(keys => {
      keyed.push((Json::array(keys.map(v => v.json)), v.json))
      Machine::empty()
    })
  })
  .collect(_ => {
    keyed.sort_by((a, b) => compare_json(a.0, b.0))
    let json = match name {
      "min_by" => keyed.get(0).map(pair => pair.1).unwrap_or(null)
      "max_by" => keyed.last().map(pair => pair.1).unwrap_or(null)
      "sort_by" => Json::array(keyed.map(pair => pair.1))
      _ => {
        let groups : Array[Array[Json]] = []
        let mut previous : Json? = None
        for (key, item) in keyed {
          if previous is Some(p) && compare_json(p, key) == 0 {
            groups[groups.length() - 1].push(item)
          } else {
            groups.push([item])
            previous = Some(key)
          }
        }
        if name == "unique_by" {
          Json::array(groups.map(g => g[0]))
        } else {
          Json::array(groups.map(Json::array))
        }
      }
    }
    Machine::one(value(json))
  })
}

///|
fn each_or_empty(
  input : Value,
  tracking : Bool,
  span : @ast.Span?,
) -> Machine raise EvalError {
  if input.json is (Array(_) | Object(_)) {
    each(input, tracking, span)
  } else {
    Machine::empty()
  }
}

///|
fn Plan::recurse(
  self : Plan,
  args : Array[Int32],
  input : Value,
  env : Env,
  tracking : Bool,
  span : @ast.Span?,
) -> Machine raise EvalError {
  check_access(input, tracking, span)
  let descend = Machine::new(
    Defer(() => {
      let children = if args.is_empty() {
        each_or_empty(input, tracking, span)
      } else {
        self.machine(args[0], input, env, tracking)
      }
      children.flat_map(v => {
        if args.length() == 2 {
          self
          .machine(args[1], v, env, false)
          .flat_map(c => {
            if @ast_internal.is_truthy(c.json) {
              self.recurse(args, v, env, tracking, span)
            } else {
              Machine::empty()
            }
          })
        } else {
          self.recurse(args, v, env, tracking, span)
        }
      })
    }),
  )
  Machine::one(input).concat(descend)
}

///|
fn Plan::loop_filter(
  self : Plan,
  name : String,
  cond : Int32,
  update : Int32,
  input : Value,
  env : Env,
  tracking : Bool,
) -> Machine {
  self
  .machine(cond, input, env, false)
  .flat_map(c => {
    let truthy = @ast_internal.is_truthy(c.json)
    if name == "until" && truthy {
      return Machine::one(input)
    }
    if name == "while" && !truthy {
      return Machine::empty()
    }
    let next = Machine::new(
      Defer(() => {
        self
        .machine(update, input, env, tracking)
        .flat_map(v => self.loop_filter(name, cond, update, v, env, tracking))
      }),
    )
    if name == "while" {
      Machine::one(input).concat(next)
    } else {
      next
    }
  })
}

///|
fn Plan::walk(
  self : Plan,
  body : Int32,
  input : Value,
  env : Env,
  span : @ast.Span?,
) -> Machine raise EvalError {
  let nested = match input.json {
    Array(_) =>
      each(input, false, span)
      .flat_map(v => self.walk(body, v, env, span))
      .collect(vs => Machine::one(value(Json::array(vs.map(v => v.json)))))
    Object(obj) => {
      let out : Map[String, Json] = Map([])
      let entries = Machine::new(
        Values(
          obj.iter().map(kv => value(Json::array([Json::string(kv.0), kv.1]))),
        ),
      )
      entries
      .flat_map(entry => {
        guard entry.json is Array(pair) else { return Machine::empty() }
        guard pair[0] is String(key) else { return Machine::empty() }
        self
        .walk(body, value(pair[1]), env, span)
        .take(1)
        .map(v => {
          out[key] = v.json
          v
        })
      })
      .collect(_ => Machine::one(value(Json::object(out))))
    }
    _ => Machine::one(value(input.json))
  }
  nested.flat_map(v => self.machine(body, v, env, false))
}

///|
fn combinations(input : Json, span : @ast.Span?) -> Machine raise EvalError {
  guard input is Array(arrays) else {
    raise EvalError(Json::string("Expected array"), span)
  }
  fn product(index : Int32, prefix : Array[Json]) -> Machine {
    if index == arrays.length() {
      return Machine::one(value(Json::array(prefix)))
    }
    Machine::new(
      Defer(() => {
        each(value(arrays[index]), false, span).flat_map(v => {
          product(index + 1, prefix + [v.json])
        })
      }),
    )
  }
  product(0, [])
}
