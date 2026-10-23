///|
/// An immutable, name-resolved query. Each evaluation owns its execution state.
pub struct Plan {
  priv entry : Int32
  priv nodes : Array[Node]
  priv functions : Array[Function]
} derive(Debug)

///|
priv struct Node {
  code : Code
  span : @ast.Span?
} derive(Debug)

///|
priv enum Code {
  Identity
  Constant(Json)
  Pipe(Int32, Int32)
  Comma(Int32, Int32)
  Access(Int32)
  Subscript(Int32, Int32)
  Each
  Slice(Int32?, Int32?)
  Collect(Int32?)
  Object(Array[(Int32, Int32?)])
  Binary(Int32, @ast.BinaryOp, Int32)
  If(Int32, Int32, Int32)
  Catch(Int32, Int32?)
  Alternative(Int32, Int32)
  Variable(Int32)
  Bind(Int32, Int32, Int32)
  Scope(Int32, Int32)
  Call(Int32, Array[Int32])
  Filter(Int32)
  Builtin(String, Array[Int32])
  Reduce(Int32, Int32, Int32, Int32, Int32?)
  Update(Int32, Int32, UpdateMode)
} derive(Debug)

///|
priv enum UpdateMode {
  Assign
  Modify
} derive(Debug)

///|
priv struct Param {
  id : Int32
  by_value : Bool
} derive(Debug)

///|
priv struct Function {
  params : Array[Param]
  body : Int32
} derive(Debug)

///|
/// Name or arity error discovered before evaluation.
pub(all) suberror CompileError {
  CompileError(String, @ast.Span?)
} derive(Debug)

///|
pub impl Show for CompileError with fn output(self, logger) {
  let CompileError(message, span) = self
  logger.write_string(message)
  if span is Some(s) {
    logger.write_string(" at UTF-16 \{s.start}..\{s.end}")
  }
}

///|
pub extend Plan with @debug.Debug::{to_repr}

///|
pub extend CompileError with @debug.Debug::{to_repr}

///|
pub extend CompileError with Show::{to_string, output}
