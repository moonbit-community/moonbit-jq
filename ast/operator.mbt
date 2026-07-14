///|
/// Binary operators in jq
pub(all) enum BinaryOp {
  Add // +
  Subtract // -
  Multiply // *
  Divide // /
  Modulo // %
  Equal // ==
  NotEqual // !=
  LessThan // <
  LessEq // <=
  GreaterThan // >
  GreaterEq // >=
  And // and
  Or // or
} derive(Eq, ToJson, Debug)

///|
/// Preserve method-style access to derived equality operations.
pub extend BinaryOp with Eq::{not_equal, equal}

///|
/// Preserve method-style access to derived JSON conversion.
pub extend BinaryOp with ToJson::{to_json}

///|
/// Preserve method-style access to derived debug representation.
pub extend BinaryOp with @debug.Debug::{to_repr}

///|
pub impl Show for BinaryOp with fn output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
/// Preserve method-style access to display operations.
pub extend BinaryOp with Show::{to_string, output}
