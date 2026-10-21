///|
priv enum ArgumentMode {
  Values
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
    ("length", 0) => Some({ mode: Values, consumption: EachResult, })
    ("keys", 0) => Some({ mode: Values, consumption: EachResult, })
    ("keys_unsorted", 0) => Some({ mode: Values, consumption: EachResult, })
    ("values", 0) => Some({ mode: Values, consumption: EachResult, })
    ("type", 0) => Some({ mode: Values, consumption: EachResult, })
    ("empty", 0) => Some({ mode: Values, consumption: EachResult, })
    ("not", 0) => Some({ mode: Values, consumption: EachResult, })
    ("sort", 0) => Some({ mode: Values, consumption: EachResult, })
    ("reverse", 0) => Some({ mode: Values, consumption: EachResult, })
    ("unique", 0) => Some({ mode: Values, consumption: EachResult, })
    ("combinations", 0) => Some({ mode: Values, consumption: EachResult, })
    ("transpose", 0) => Some({ mode: Values, consumption: EachResult, })
    ("add", 0) => Some({ mode: Values, consumption: EachResult, })
    ("floor", 0) => Some({ mode: Values, consumption: EachResult, })
    ("sqrt", 0) => Some({ mode: Values, consumption: EachResult, })
    ("min", 0) => Some({ mode: Values, consumption: EachResult, })
    ("max", 0) => Some({ mode: Values, consumption: EachResult, })
    ("round", 0) => Some({ mode: Values, consumption: EachResult, })
    ("ceil", 0) => Some({ mode: Values, consumption: EachResult, })
    ("abs", 0) => Some({ mode: Values, consumption: EachResult, })
    ("to_entries", 0) => Some({ mode: Values, consumption: EachResult, })
    ("from_entries", 0) => Some({ mode: Values, consumption: EachResult, })
    ("ascii_upcase", 0) => Some({ mode: Values, consumption: EachResult, })
    ("ascii_downcase", 0) => Some({ mode: Values, consumption: EachResult, })
    ("explode", 0) => Some({ mode: Values, consumption: EachResult, })
    ("implode", 0) => Some({ mode: Values, consumption: EachResult, })
    ("tojson", 0) => Some({ mode: Values, consumption: EachResult, })
    ("tostring", 0) => Some({ mode: Values, consumption: EachResult, })
    ("fromjson", 0) => Some({ mode: Values, consumption: EachResult, })
    ("log", 0) => Some({ mode: Values, consumption: EachResult, })
    ("exp", 0) => Some({ mode: Values, consumption: EachResult, })
    ("sin", 0) => Some({ mode: Values, consumption: EachResult, })
    ("cos", 0) => Some({ mode: Values, consumption: EachResult, })
    ("tan", 0) => Some({ mode: Values, consumption: EachResult, })
    ("asin", 0) => Some({ mode: Values, consumption: EachResult, })
    ("acos", 0) => Some({ mode: Values, consumption: EachResult, })
    ("atan", 0) => Some({ mode: Values, consumption: EachResult, })
    ("split", 1) => Some({ mode: Values, consumption: EachResult, })
    ("join", 1) => Some({ mode: Values, consumption: EachResult, })
    ("startswith", 1) => Some({ mode: Values, consumption: EachResult, })
    ("endswith", 1) => Some({ mode: Values, consumption: EachResult, })
    ("contains", 1) => Some({ mode: Values, consumption: EachResult, })
    ("inside", 1) => Some({ mode: Values, consumption: EachResult, })
    ("has", 1) => Some({ mode: Values, consumption: EachResult, })
    ("in", 1) => Some({ mode: Values, consumption: EachResult, })
    ("indices", 1) => Some({ mode: Values, consumption: EachResult, })
    ("index", 1) => Some({ mode: Values, consumption: EachResult, })
    ("rindex", 1) => Some({ mode: Values, consumption: EachResult, })
    ("ltrimstr", 1) => Some({ mode: Values, consumption: EachResult, })
    ("rtrimstr", 1) => Some({ mode: Values, consumption: EachResult, })
    ("test", 1) => Some({ mode: Values, consumption: EachResult, })
    ("match", 1) => Some({ mode: Values, consumption: EachResult, })
    ("capture", 1) => Some({ mode: Values, consumption: EachResult, })
    ("scan", 1) => Some({ mode: Values, consumption: EachResult, })
    ("splits", 1) => Some({ mode: Values, consumption: EachResult, })
    ("getpath", 1) => Some({ mode: Values, consumption: EachResult, })
    ("delpaths", 1) => Some({ mode: Values, consumption: EachResult, })
    ("setpath", 2) => Some({ mode: Values, consumption: EachResult, })
    ("sub", 2) => Some({ mode: Values, consumption: EachResult, })
    ("gsub", 2) => Some({ mode: Values, consumption: EachResult, })
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
    ("flatten", 0) => Some({ mode: Values, consumption: EachResult, })
    ("flatten", 1) => Some({ mode: Values, consumption: EachResult, })
    ("range", 1) => Some({ mode: Values, consumption: EachResult, })
    ("range", 2) => Some({ mode: Values, consumption: EachResult, })
    ("range", 3) => Some({ mode: Values, consumption: EachResult, })
    ("first", 0) => Some({ mode: Filters, consumption: FirstResult, })
    ("first", 1) => Some({ mode: Filters, consumption: FirstResult, })
    ("last", 0) => Some({ mode: Filters, consumption: CollectAll, })
    ("last", 1) => Some({ mode: Filters, consumption: CollectAll, })
    ("nth", 1) => Some({ mode: Mixed, consumption: FirstResult, })
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
    ("pow", 1) => Some({ mode: Values, consumption: EachResult, })
    ("pow", 2) => Some({ mode: Values, consumption: EachResult, })
    ("error", 0) => Some({ mode: Values, consumption: EachResult, })
    ("error", 1) => Some({ mode: Values, consumption: EachResult, })
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
    ) => Some({ mode: Values, consumption: EachResult, })
    _ => None
  }
}
