///|
/// Environment for variable and function bindings
priv struct Env {
  bindings : Map[String, Json]
  functions : Map[String, (Expr, Array[String])] // (body, params)
}

///|
fn Env::new() -> Env {
  { bindings: {}, functions: {} }
}

///|
fn Env::get(self : Env, name : String) -> Json? {
  self.bindings.get(name)
}

///|
fn Env::set(self : Env, name : String, value : Json) -> Env {
  let new_bindings = self.bindings.copy()
  new_bindings[name] = value
  { bindings: new_bindings, functions: self.functions }
}

///|
fn Env::extend(self : Env, name : String, value : Json) -> Env {
  let new_bindings = self.bindings.copy()
  let new_funcs = self.functions.copy()
  new_bindings[name] = value
  { bindings: new_bindings, functions: new_funcs }
}

///|
fn Env::set_function(
  self : Env,
  name : String,
  body : Expr,
  params : Array[String],
) -> Env {
  let new_bindings = self.bindings.copy()
  let new_funcs = self.functions.copy()
  new_funcs[name] = (body, params)
  { bindings: new_bindings, functions: new_funcs }
}

///|
fn Env::get_function(self : Env, name : String) -> (Expr, Array[String])? {
  self.functions.get(name)
}
