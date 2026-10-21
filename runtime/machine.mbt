///|
priv struct Value {
  json : Json
  path : Array[Json]?
}

///|
fn value(json : Json) -> Value {
  { json, path: None, }
}

///|
priv enum Binding {
  Bound(Json)
  Closure(Int32, Env)
}

///|
priv struct Env {
  values : Map[Int32, Binding]
  functions : Map[Int32, Env]
}

///|
fn Env::new() -> Env {
  { values: {}, functions: {}, }
}

///|
fn Env::bind(self : Env, id : Int32, binding : Binding) -> Env {
  let values = self.values.copy()
  values[id] = binding
  { values, functions: self.functions, }
}

///|
type Event = Result[Value, EvalError]?

///|
priv enum Frame {
  Run(Plan, Int32, Value, Env, Bool)
  Emit(Value)
  Fail(EvalError)
  Drain(Machine)
  Values(Iter[Value])
  FlatMap(Machine, (Value) -> Machine raise EvalError)
  Map(Machine, (Value) -> Value raise EvalError)
  Catch(Machine, (EvalError) -> Machine)
  Collect(Machine, Array[Value], (Array[Value]) -> Machine raise EvalError)
  Take(Machine, Int32)
  Last(Machine, Json)
  Alternative(Machine, Bool, () -> Machine)
  Defer(() -> Machine raise EvalError)
  Repeat(() -> Machine)
}

///|
priv struct Machine {
  frames : Array[Frame]
  mut done : Bool
}

///|
priv enum Step {
  Again
  Ready(Event)
  Await(Machine, (Event) -> Unit raise EvalError)
}

///|
fn Machine::new(frame : Frame) -> Machine {
  { frames: [frame], done: false, }
}

///|
fn Machine::empty() -> Machine {
  { frames: [], done: false, }
}

///|
fn Machine::one(v : Value) -> Machine {
  Machine::new(Emit(v))
}

///|
fn Machine::fail(err : EvalError) -> Machine {
  Machine::new(Fail(err))
}

///|
fn Machine::map(
  self : Machine,
  f : (Value) -> Value raise EvalError,
) -> Machine {
  Machine::new(Map(self, f))
}

///|
fn Machine::flat_map(
  self : Machine,
  f : (Value) -> Machine raise EvalError,
) -> Machine {
  Machine::new(FlatMap(self, f))
}

///|
fn Machine::collect(
  self : Machine,
  f : (Array[Value]) -> Machine raise EvalError,
) -> Machine {
  Machine::new(Collect(self, [], f))
}

///|
fn Machine::take(self : Machine, count : Int32) -> Machine {
  Machine::new(Take(self, count))
}

///|
fn Machine::concat(self : Machine, other : Machine) -> Machine {
  { frames: [Drain(other), Drain(self)], done: false, }
}

///|
fn Machine::accept(self : Machine, event : Event) -> Unit {
  match event {
    Some(Ok(v)) => self.frames.push(Emit(v))
    Some(Err(e)) => self.frames.push(Fail(e))
    None => ()
  }
}

///|
fn Machine::step(self : Machine) -> Step raise EvalError {
  if self.done {
    return Ready(None)
  }
  guard self.frames.pop() is Some(frame) else { return Ready(None) }
  match frame {
    Run(plan, node, input, env, tracking) => {
      self.frames.push(Drain(plan.start(node, input, env, tracking)))
      Again
    }
    Emit(v) => Ready(Some(Ok(v)))
    Fail(e) => Ready(Some(Err(e)))
    Values(values) =>
      match values.next() {
        Some(v) => {
          self.frames.push(Values(values))
          Ready(Some(Ok(v)))
        }
        None => Again
      }
    Drain(child) =>
      Await(child, event => {
        if event is Some(Ok(_)) {
          self.frames.push(Drain(child))
        }
        self.accept(event)
      })
    FlatMap(child, f) =>
      Await(child, event => {
        match event {
          Some(Ok(v)) => {
            self.frames.push(FlatMap(child, f))
            self.frames.push(Drain(f(v)))
          }
          _ => self.accept(event)
        }
      })
    Map(child, f) =>
      Await(child, event => {
        match event {
          Some(Ok(v)) => {
            self.frames.push(Map(child, f))
            self.frames.push(Emit(f(v)))
          }
          _ => self.accept(event)
        }
      })
    Catch(child, handler) =>
      Await(child, event => {
        match event {
          Some(Err(e)) => self.frames.push(Drain(handler(e)))
          Some(Ok(_)) => {
            self.frames.push(Catch(child, handler))
            self.accept(event)
          }
          None => ()
        }
      })
    Collect(child, values, f) =>
      Await(child, event => {
        match event {
          Some(Ok(v)) => {
            values.push(v)
            self.frames.push(Collect(child, values, f))
          }
          Some(Err(_)) => self.accept(event)
          None => self.frames.push(Drain(f(values)))
        }
      })
    Last(child, last) =>
      Await(child, event => {
        match event {
          Some(Ok(v)) => self.frames.push(Last(child, v.json))
          Some(Err(_)) => self.accept(event)
          None => self.frames.push(Emit(value(last)))
        }
      })
    Take(child, n) =>
      if n <= 0 {
        Again
      } else {
        Await(child, event => {
          if event is Some(Ok(_)) && n > 1 {
            self.frames.push(Take(child, n - 1))
          }
          self.accept(event)
        })
      }
    Alternative(child, seen, fallback) =>
      Await(child, event => {
        match event {
          Some(Ok(v)) => {
            let truthy = @ast_internal.is_truthy(v.json)
            self.frames.push(Alternative(child, seen || truthy, fallback))
            if truthy {
              self.frames.push(Emit(v))
            }
          }
          Some(Err(_)) => self.accept(event)
          None => if !seen { self.frames.push(Drain(fallback())) }
        }
      })
    Defer(f) => {
      self.frames.push(Drain(f()))
      Again
    }
    Repeat(f) => {
      self.frames.push(Repeat(f))
      self.frames.push(Drain(f()))
      Again
    }
  }
}

///|
/// Trampoline: polling a nested stream never recursively calls `next`.
/// The wait stack is also what limits catch scopes to their own substreams.
fn Machine::next(self : Machine) -> Event {
  let waiting : Array[(Machine, (Event) -> Unit raise EvalError)] = []
  let mut current = self
  while true {
    let step = current.step() catch { err => Ready(Some(Err(err))) }
    match step {
      Again => continue
      Await(child, on_event) => {
        waiting.push((current, on_event))
        current = child
      }
      Ready(event) => {
        if event is (None | Some(Err(_))) {
          current.done = true
          current.frames.clear()
        }
        match waiting.pop() {
          None => return event
          Some((parent, on_event)) => {
            current = parent
            on_event(event) catch {
              err => current.frames.push(Fail(err))
            }
          }
        }
      }
    }
  } nobreak {
    None
  }
}

///|
fn Plan::machine(
  self : Plan,
  node : Int32,
  input : Value,
  env : Env,
  tracking : Bool,
) -> Machine {
  Machine::new(Run(self, node, input, env, tracking))
}

///|
/// Create a suspended result stream. No query code runs until `next` is called.
pub fn eval(plan : Plan, input : Json) -> Iter[Result[Json, EvalError]] {
  let machine = plan.machine(
    plan.entry,
    { json: input, path: Some([]), },
    Env::new(),
    false,
  )
  Iter::new(fn() { machine.next().map(event => event.map(v => v.json)) })
}

///|
/// Consume the same stream as `eval`, raising its first error.
pub fn eval_all(plan : Plan, input : Json) -> Array[Json] raise EvalError {
  let out : Array[Json] = []
  for result in eval(plan, input) {
    match result {
      Ok(v) => out.push(v)
      Err(e) => raise e
    }
  }
  out
}
