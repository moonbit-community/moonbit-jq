///|
/// Every syntax node has a source region. Implicit syntax (the identity before
/// `.[]`, the zero used for unary minus) inherits the region that introduced it.
/// Redundant precedence/parenthesis wrappers are collapsed to the outer region.
fn complete_locations(expr : @ast.Expr, fallback : @ast.Span) -> @ast.Expr {
  match expr {
    Located(span, inner) => Located(span, locate_children(inner, span))
    _ => Located(fallback, locate_children(expr, fallback))
  }
}

///|
fn locate_children(expr : @ast.Expr, span : @ast.Span) -> @ast.Expr {
  fn child(e : @ast.Expr) -> @ast.Expr {
    complete_locations(e, span)
  }
  match expr {
    Located(_, inner) => locate_children(inner, span)
    Pipe(a, b) => Pipe(child(a), child(b))
    Comma(a, b) => Comma(child(a), child(b))
    Access(key) => Access(child(key))
    Subscript(base, key) => Subscript(child(base), child(key))
    Optional(body) => Optional(child(body))
    ArrayConstruct(body) => ArrayConstruct(body.map(child))
    ObjectConstruct(fields) =>
      ObjectConstruct(fields.map(pair => (child(pair.0), pair.1.map(child))))
    Operation(a, op, b) => Operation(child(a), op, child(b))
    IfThenElse(c, a, b) => IfThenElse(child(c), child(a), child(b))
    TryCatch(body, handler) => TryCatch(child(body), handler.map(child))
    As(source, name, body) => As(child(source), name, child(body))
    Reduce(gen, name, init, update) =>
      Reduce(child(gen), name, child(init), child(update))
    Foreach(gen, name, init, update, extract) =>
      Foreach(child(gen), name, child(init), child(update), extract.map(child))
    Update(a, b) => Update(child(a), child(b))
    Assign(a, b) => Assign(child(a), child(b))
    Alternative(a, b) => Alternative(child(a), child(b))
    AddAssign(a, b) => AddAssign(child(a), child(b))
    SubAssign(a, b) => SubAssign(child(a), child(b))
    MulAssign(a, b) => MulAssign(child(a), child(b))
    DivAssign(a, b) => DivAssign(child(a), child(b))
    ModAssign(a, b) => ModAssign(child(a), child(b))
    AltAssign(a, b) => AltAssign(child(a), child(b))
    StringInterpolation(parts) =>
      StringInterpolation(parts.map(pair => (pair.0, pair.1.map(child))))
    FunctionDef(name, params, body) => FunctionDef(name, params, child(body))
    Scope(name, params, body, rest) =>
      Scope(name, params, child(body), child(rest))
    FunctionCall(name, args) => FunctionCall(name, args.map(child))
    Identity
    | Literal(_)
    | Key(_)
    | Index(_)
    | Slice(_, _)
    | Variable(_)
    | Format(_) => expr
  }
}
