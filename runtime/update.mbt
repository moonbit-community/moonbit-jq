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
    Modify => self.modify(paths(), body, input.json, env, None, span)
    AlternativeAssign =>
      self.modify(paths(), body, input.json, env, Some((None, input)), span)
    Assign | Compound(_) =>
      self
      .machine(body, input, env, false)
      .flat_map(rhs => {
        match mode {
          Compound(op) =>
            self.modify(
              paths(),
              body,
              input.json,
              env,
              Some((Some(op), rhs)),
              span,
            )
          _ => {
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
          }
        }
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
  operation : (@ast.BinaryOp?, Value)?,
  span : @ast.Span?,
) -> Machine {
  let updated = Ref(original)
  let deleted : Array[Array[Json]] = []
  paths
  .flat_map(entry => {
    let p = path_result(entry, span)
    guard p.json is Array(segments) else { return Machine::empty() }
    let current = get_at_path(updated.val, segments).unwrap_or(null)
    let changes = match operation {
      None => self.machine(body, value(current), env, false).take(1)
      Some((Some(op), rhs)) => {
        let next = eval_binary_op(op, current, rhs.json) catch {
          err => raise primitive_error(err, span)
        }
        Machine::one(value(next))
      }
      Some((None, input)) =>
        if @ast_internal.is_truthy(current) {
          Machine::one(value(current))
        } else {
          self.machine(body, input, env, false).take(1)
        }
    }
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
    Machine::one(value(delete_paths(updated.val, deleted.map(p => p))))
  })
}
