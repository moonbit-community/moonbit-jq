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
  let new_bindings : Map[String, Json] = {}
  for k, v in self.bindings {
    new_bindings[k] = v
  }
  new_bindings[name] = value
  { bindings: new_bindings, functions: self.functions }
}

///|
fn Env::set_function(
  self : Env,
  name : String,
  body : Expr,
  params : Array[String],
) -> Env {
  let new_bindings : Map[String, Json] = {}
  for k, v in self.bindings {
    new_bindings[k] = v
  }
  let new_funcs : Map[String, (Expr, Array[String])] = {}
  for k, v in self.functions {
    new_funcs[k] = v
  }
  new_funcs[name] = (body, params)
  { bindings: new_bindings, functions: new_funcs }
}

///|
fn Env::get_function(self : Env, name : String) -> (Expr, Array[String])? {
  self.functions.get(name)
}
