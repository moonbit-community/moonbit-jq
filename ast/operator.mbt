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
pub impl Show for BinaryOp with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}
