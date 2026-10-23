///|
priv struct Compiler {
  nodes : Array[Node]
  functions : Array[Function]
  mut binding : Int32
}

///|
priv struct Names {
  variables : Map[String, Int32]
  functions : Map[String, (Int32, Int32)]
  filters : Map[String, Int32]
}

///|
fn Names::copy(self : Names) -> Names {
  {
    variables: self.variables.copy(),
    functions: self.functions.copy(),
    filters: self.filters.copy(),
  }
}

///|
fn Compiler::fresh(self : Compiler) -> Int32 {
  let id = self.binding
  self.binding += 1
  id
}

///|
fn Compiler::node(self : Compiler, code : Code, span : @ast.Span?) -> Int32 {
  let id = self.nodes.length()
  self.nodes.push({ code, span, })
  id
}

///|
/// Resolve names and expand syntax into a reusable execution plan.
pub fn compile(expr : @ast.Expr) -> Plan raise CompileError {
  let compiler : Compiler = { nodes: [], functions: [], binding: 0, }
  let names : Names = { variables: {}, functions: {}, filters: {}, }
  let entry = compiler.expr(expr, names, None)
  { entry, nodes: compiler.nodes, functions: compiler.functions, }
}

///|
fn Compiler::scope(
  self : Compiler,
  name : String,
  params : Array[String],
  body : @ast.Expr,
  rest : @ast.Expr,
  names : Names,
  span : @ast.Span?,
) -> Int32 raise CompileError {
  let id = self.functions.length()
  let outer = names.copy()
  outer.functions[name + "/" + params.length().to_string()] = (
    id,
    params.length(),
  )
  let inner = outer.copy()
  let parameters = params.map(p => {
    let id = self.fresh()
    let by_value = p.has_prefix("$")
    if by_value {
      inner.variables[p[1:].to_owned()] = id
    } else {
      inner.filters[p] = id
    }
    { id, by_value, }
  })
  self.functions.push({ params: parameters, body: 0, })
  let body = self.expr(body, inner, span)
  self.functions[id] = { params: parameters, body, }
  self.node(Scope(id, self.expr(rest, outer, span)), span)
}

///|
fn Compiler::compound_update(
  self : Compiler,
  path : Int32,
  rhs : Int32,
  op : @ast.BinaryOp?,
  span : @ast.Span?,
) -> Code {
  let binding = self.fresh()
  let current = self.node(Identity, span)
  let saved = self.node(Variable(binding), span)
  let body = self.node(
    match op {
      Some(op) => Binary(current, op, saved)
      None => Alternative(current, saved)
    },
    span,
  )
  Bind(rhs, binding, self.node(Update(path, body, Modify), span))
}

///|
fn Compiler::expr(
  self : Compiler,
  expr : @ast.Expr,
  names : Names,
  span : @ast.Span?,
) -> Int32 raise CompileError {
  fn child(e : @ast.Expr) -> Int32 raise CompileError {
    self.expr(e, names, span)
  }
  let code : Code = match expr {
    Located(at, inner) => return self.expr(inner, names, Some(at))
    Identity => Identity
    Literal(lit) => Constant(eval_literal(lit))
    Scope(name, params, body, rest) =>
      return self.scope(name, params, body, rest, names, span)
    Pipe(FunctionDef(name, params, body), rest) =>
      return self.scope(name, params, body, rest, names, span)
    FunctionDef(name, params, body) =>
      return self.scope(name, params, body, Identity, names, span)
    Pipe(a, b) => Pipe(child(a), child(b))
    Comma(a, b) => Comma(child(a), child(b))
    Key(key) => Access(self.node(Constant(Json::string(key)), span))
    Access(key) => Access(child(key))
    Subscript(base, key) => Subscript(child(base), child(key))
    Index([]) => Each
    Index(indices) => {
      let keys = indices.map(i => {
        self.node(Constant(Json::number(i.to_double())), span)
      })
      let mut key = keys[0]
      for i in 1..<keys.length() {
        key = self.node(Comma(key, keys[i]), span)
      }
      Access(key)
    }
    Slice(a, b) => Slice(a, b)
    Optional(body) => Catch(child(body), None)
    ArrayConstruct(body) => Collect(body.map(child))
    ObjectConstruct(fields) =>
      Object(fields.map(pair => (child(pair.0), pair.1.map(child))))
    Operation(a, op, b) => Binary(child(a), op, child(b))
    IfThenElse(c, a, b) => If(child(c), child(a), child(b))
    TryCatch(a, b) => Catch(child(a), b.map(child))
    Alternative(a, b) => Alternative(child(a), child(b))
    Variable(name) =>
      match names.variables.get(name) {
        Some(id) => Variable(id)
        None => raise CompileError("Undefined variable: $" + name, span)
      }
    As(source, name, body) => {
      let source = child(source)
      let inner = names.copy()
      let id = self.fresh()
      inner.variables[name] = id
      Bind(source, id, self.expr(body, inner, span))
    }
    Reduce(gen, name, init, update) | Foreach(gen, name, init, update, None) => {
      let gen = child(gen)
      let init = child(init)
      let inner = names.copy()
      let id = self.fresh()
      inner.variables[name] = id
      let update = self.expr(update, inner, span)
      let extract = if expr is Foreach(_, _, _, _, _) {
        Some(self.node(Identity, span))
      } else {
        None
      }
      Reduce(gen, id, init, update, extract)
    }
    Foreach(gen, name, init, update, Some(extract)) => {
      let gen = child(gen)
      let init = child(init)
      let inner = names.copy()
      let id = self.fresh()
      inner.variables[name] = id
      Reduce(
        gen,
        id,
        init,
        self.expr(update, inner, span),
        Some(self.expr(extract, inner, span)),
      )
    }
    Update(path, value) => Update(child(path), child(value), Modify)
    Assign(path, value) => Update(child(path), child(value), Assign)
    AddAssign(path, value) =>
      self.compound_update(child(path), child(value), Some(Add), span)
    SubAssign(path, value) =>
      self.compound_update(child(path), child(value), Some(Subtract), span)
    MulAssign(path, value) =>
      self.compound_update(child(path), child(value), Some(Multiply), span)
    DivAssign(path, value) =>
      self.compound_update(child(path), child(value), Some(Divide), span)
    ModAssign(path, value) =>
      self.compound_update(child(path), child(value), Some(Modulo), span)
    AltAssign(path, value) =>
      self.compound_update(child(path), child(value), None, span)
    StringInterpolation(parts) => {
      let mut result = self.node(Constant(Json::string("")), span)
      for (text, expr) in parts {
        if text != "" {
          result = self.node(
            Binary(result, Add, self.node(Constant(Json::string(text)), span)),
            span,
          )
        }
        if expr is Some(e) {
          let value = child(e)
          let text = self.node(Builtin("tostring", []), self.nodes[value].span)
          let converted = self.node(Pipe(value, text), self.nodes[value].span)
          result = self.node(Binary(result, Add, converted), span)
        }
      }
      return result
    }
    FunctionCall(name, args) => {
      let arity = args.length()
      if arity == 0 && names.filters.get(name) is Some(id) {
        return self.node(Filter(id), span)
      }
      if names.functions.get(name + "/" + arity.to_string()) is Some((id, _)) {
        Call(id, args.map(child))
      } else {
        guard builtin_spec(name, arity) is Some(_) else {
          raise CompileError(
            "Undefined function: " + name + "/" + arity.to_string(),
            span,
          )
        }
        Builtin(name, args.map(child))
      }
    }
    Format(name) => Builtin("@" + name, [])
  }
  self.node(code, span)
}
