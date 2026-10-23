///|
priv enum ArgumentOrder {
  LeftToRight
  RightToLeft
}

///|
priv enum ArgumentMode {
  Values(ArgumentOrder)
  Filters
  Mixed
}

///|
priv enum Consumption {
  EachResult
  CollectAll
  FirstResult
  ShortCircuit
}

///|
priv struct BuiltinSpec {
  mode : ArgumentMode
  consumption : Consumption
}

///|
fn builtin_spec(name : String, arity : Int32) -> BuiltinSpec? {
  match (name, arity) {
    ("length", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("keys", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("keys_unsorted", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("values", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("type", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("empty", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("not", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("sort", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("reverse", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("unique", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("combinations", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("transpose", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("add", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("floor", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("sqrt", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("min", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("max", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("round", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("ceil", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("abs", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("to_entries", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("from_entries", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("ascii_upcase", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("ascii_downcase", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("explode", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("implode", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("tojson", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("tostring", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("fromjson", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("log", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("exp", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("sin", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("cos", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("tan", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("asin", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("acos", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("atan", 0) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("split", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("join", 1) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("startswith", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("endswith", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("contains", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("inside", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("has", 1) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("in", 1) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("indices", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("index", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("rindex", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("ltrimstr", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("rtrimstr", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("test", 1) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("match", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("capture", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("scan", 1) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("splits", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("getpath", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("delpaths", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("setpath", 2) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("sub", 2) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("gsub", 2) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("map", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("select", 1) => Some({ mode: Filters, consumption: EachResult, })
    ("sort_by", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("group_by", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("unique_by", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("min_by", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("max_by", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("with_entries", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("map_values", 1) => Some({ mode: Filters, consumption: FirstResult, })
    ("repeat", 1) => Some({ mode: Filters, consumption: EachResult, })
    ("walk", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("path", 1) => Some({ mode: Filters, consumption: EachResult, })
    ("flatten", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("flatten", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("range", 1) =>
      Some({ mode: Values(LeftToRight), consumption: EachResult, })
    ("range", 2) =>
      Some({ mode: Values(LeftToRight), consumption: EachResult, })
    ("range", 3) =>
      Some({ mode: Values(LeftToRight), consumption: EachResult, })
    ("first", 0) => Some({ mode: Filters, consumption: FirstResult, })
    ("first", 1) => Some({ mode: Filters, consumption: FirstResult, })
    ("last", 0) => Some({ mode: Filters, consumption: CollectAll, })
    ("last", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("nth", 1) => Some({ mode: Values(RightToLeft), consumption: FirstResult, })
    ("nth", 2) => Some({ mode: Mixed, consumption: FirstResult, })
    ("any", 0) => Some({ mode: Filters, consumption: ShortCircuit, })
    ("any", 1) => Some({ mode: Filters, consumption: ShortCircuit, })
    ("any", 2) => Some({ mode: Filters, consumption: ShortCircuit, })
    ("all", 0) => Some({ mode: Filters, consumption: ShortCircuit, })
    ("all", 1) => Some({ mode: Filters, consumption: ShortCircuit, })
    ("all", 2) => Some({ mode: Filters, consumption: ShortCircuit, })
    ("recurse", 0) => Some({ mode: Filters, consumption: EachResult, })
    ("recurse", 1) => Some({ mode: Filters, consumption: EachResult, })
    ("recurse", 2) => Some({ mode: Filters, consumption: EachResult, })
    ("paths", 0) => Some({ mode: Filters, consumption: EachResult, })
    ("paths", 1) => Some({ mode: Filters, consumption: EachResult, })
    ("leaf_paths", 0) => Some({ mode: Filters, consumption: EachResult, })
    ("limit", 2) => Some({ mode: Mixed, consumption: FirstResult, })
    ("until", 2) => Some({ mode: Filters, consumption: EachResult, })
    ("while", 2) => Some({ mode: Filters, consumption: EachResult, })
    ("pow", 1) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("pow", 2) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("error", 0) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    ("error", 1) =>
      Some({ mode: Values(RightToLeft), consumption: EachResult, })
    (
      "numbers"
      | "strings"
      | "scalars"
      | "booleans"
      | "nulls"
      | "arrays"
      | "objects"
      | "iterables",
      0,
    ) => Some({ mode: Values(RightToLeft), consumption: EachResult, })
    _ => None
  }
}
