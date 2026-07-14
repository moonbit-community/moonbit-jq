///|
/// Token types for jq lexer
pub(all) enum Token {
  // Literals
  TNumber(Double)
  TString(String)
  TStringInterpolation(Array[(String, String?)]) // parts with optional expressions
  TTrue
  TFalse
  TNull
  TIdentifier(String)
  TVariable(String) // $name
  TFormat(String) // @base64, @uri, etc.
  // Operators
  TDot // .
  TDotDot // ..
  TPipe // |
  TComma // ,
  TColon // :
  TSemicolon // ;
  TQuestion // ?
  // Brackets
  TLParen // (
  TRParen // )
  TLBracket // [
  TRBracket // ]
  TLBrace // {
  TRBrace // }
  // Arithmetic
  TPlus // +
  TMinus // -
  TStar // *
  TSlash // /
  TPercent // %
  // Comparison
  TEq // ==
  TNeq // !=
  TLt // <
  TLe // <=
  TGt // >
  TGe // >=
  // Assignment
  TAssign // =
  TUpdate // |=
  TAlternative // //
  TAddAssign // +=
  TSubAssign // -=
  TMulAssign // *=
  TDivAssign // /=
  TModAssign // %=
  TAltAssign // //=
  // Keywords
  TAnd // and
  TOr // or
  TNot // not
  TIf // if
  TThen // then
  TElse // else
  TElif // elif
  TEnd // end
  TAs // as
  TReduce // reduce
  TForeach // foreach
  TTry // try
  TCatch // catch
  TDef // def
  TEof
} derive(Eq, Debug)

///|
/// Preserve method-style access to derived equality operations.
pub extend Token with Eq::{not_equal, equal}

///|
/// Preserve method-style access to derived debug representation.
pub extend Token with @debug.Debug::{to_repr}

///|
pub impl Show for Token with fn output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
/// Preserve method-style access to display operations.
pub extend Token with Show::{to_string, output}
