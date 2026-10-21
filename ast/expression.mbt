///|
/// Syntax only. Calls are resolved and interpolation is expanded by runtime.compile.
pub(all) enum Expr {
  Located(Span, Expr)
  Identity
  Literal(Literal)
  Pipe(Expr, Expr)
  Comma(Expr, Expr)
  Key(String)
  Access(Expr)
  Subscript(Expr, Expr)
  Index(Array[Int32])
  Slice(Int32?, Int32?)
  Optional(Expr)
  ArrayConstruct(Expr?)
  ObjectConstruct(Array[(Expr, Expr?)])
  Operation(Expr, BinaryOp, Expr)
  IfThenElse(Expr, Expr, Expr)
  TryCatch(Expr, Expr?)
  Variable(String)
  As(Expr, String, Expr)
  Reduce(Expr, String, Expr, Expr)
  Foreach(Expr, String, Expr, Expr, Expr?)
  Update(Expr, Expr)
  Assign(Expr, Expr)
  Alternative(Expr, Expr)
  AddAssign(Expr, Expr)
  SubAssign(Expr, Expr)
  MulAssign(Expr, Expr)
  DivAssign(Expr, Expr)
  ModAssign(Expr, Expr)
  AltAssign(Expr, Expr)
  Format(String)
  StringInterpolation(Array[(String, Expr?)])
  FunctionDef(String, Array[String], Expr)
  Scope(String, Array[String], Expr, Expr)
  FunctionCall(String, Array[Expr])
} derive(Eq, ToJson, Debug)

///|
/// Preserve method-style access to derived equality operations.
pub extend Expr with Eq::{not_equal, equal}

///|
/// Preserve method-style access to derived JSON conversion.
pub extend Expr with ToJson::{to_json}

///|
/// Preserve method-style access to derived debug representation.
pub extend Expr with @debug.Debug::{to_repr}

///|
pub impl Show for Expr with fn output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
/// Preserve method-style access to display operations.
pub extend Expr with Show::{to_string, output}
