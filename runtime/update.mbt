///|
fn Plan::update(
  self : Plan,
  path : Int32,
  body : Int32,
  mode : UpdateMode,
  input : Value,
  env : Env,
  span : @ast.Span?,
) -> Machine {
  fn paths() -> Machine {
    self.machine(path, { json: input.json, path: Some([]), }, env, true)
  }
  match mode {
    Modify => self.modify(paths(), body, input.json, env, span)
    Assign =>
      self
      .machine(body, input, env, false)
      .flat_map(rhs => {
        let updated = Ref(input.json)
        paths()
        .map(v => {
          let p = path_result(v, span)
          guard p.json is Array(segments) else { return v }
          updated.val = set_at_path(updated.val, segments, rhs.json) catch {
            err => raise primitive_error(err, span)
          }
          v
        })
        .collect(_ => Machine::one(value(updated.val)))
      })
  }
}

///|
fn Plan::modify(
  self : Plan,
  paths : Machine,
  body : Int32,
  original : Json,
  env : Env,
  span : @ast.Span?,
) -> Machine {
  let updated = Ref(original)
  let deleted : Array[Array[Json]] = []
  paths
  .flat_map(entry => {
    let p = path_result(entry, span)
    guard p.json is Array(segments) else { return Machine::empty() }
    let current = get_at_path(updated.val, segments).unwrap_or(null)
    let changes = self.machine(body, value(current), env, false).take(1)
    changes.collect(vs => {
      match vs.get(0) {
        Some(v) =>
          updated.val = set_at_path(updated.val, segments, v.json) catch {
            err => raise primitive_error(err, span)
          }
        None => deleted.push(segments)
      }
      Machine::empty()
    })
  })
  .collect(_ => {
    let result = delete_paths(updated.val, deleted.map(p => p)) catch {
      err => raise primitive_error(err, span)
    }
    Machine::one(value(result))
  })
}
