///|
/// Pure JSON operations cannot invoke filters. Arguments have already been
/// expanded by the machine according to the builtin registry.
fn pure_builtin(
  name : String,
  input : Json,
  args : Array[Json],
) -> Iter[Json] raise PrimitiveError {
  match name {
    "length" => eval_length(input)
    "sort" => eval_sort(input)
    "reverse" => eval_reverse(input)
    "unique" => eval_unique(input)
    "transpose" => eval_transpose(input)
    "add" => eval_add(input)
    "floor" => eval_floor(input)
    "sqrt" => eval_sqrt(input)
    "min" => eval_min(input)
    "max" => eval_max(input)
    "round" => eval_round(input)
    "ceil" => eval_ceil(input)
    "abs" => eval_abs(input)
    "to_entries" => eval_to_entries(input)
    "from_entries" => eval_from_entries(input)
    "ascii_upcase" => eval_ascii_upcase(input)
    "ascii_downcase" => eval_ascii_downcase(input)
    "explode" => eval_explode(input)
    "implode" => eval_implode(input)
    "tojson" => eval_to_json_string(input)
    "fromjson" => eval_from_json_string(input)
    "log" => eval_log(input)
    "exp" => eval_exp(input)
    "sin" => eval_sin(input)
    "cos" => eval_cos(input)
    "tan" => eval_tan(input)
    "asin" => eval_asin(input)
    "acos" => eval_acos(input)
    "atan" => eval_atan(input)
    "type" => eval_type(input)
    "not" => eval_not(input)
    "split" => eval_split(string_arg(args[0]), input)
    "join" => eval_join(string_arg(args[0]), input)
    "startswith" => eval_starts_with(string_arg(args[0]), input)
    "endswith" => eval_ends_with(string_arg(args[0]), input)
    "ltrimstr" => eval_ltrim_str(string_arg(args[0]), input)
    "rtrimstr" => eval_rtrim_str(string_arg(args[0]), input)
    "test" => eval_test(string_arg(args[0]), input)
    "match" => eval_match(string_arg(args[0]), input)
    "capture" => eval_capture(string_arg(args[0]), input)
    "scan" => eval_scan(string_arg(args[0]), input)
    "splits" => eval_splits(string_arg(args[0]), input)
    "sub" => eval_sub(string_arg(args[0]), string_arg(args[1]), input)
    "gsub" => eval_gsub(string_arg(args[0]), string_arg(args[1]), input)
    "flatten" =>
      eval_flatten(
        if args.is_empty() {
          None
        } else {
          Some(numeric_arg(args[0]).to_int())
        },
        input,
      )
    "tostring" => Iter::singleton(Json::string(json_to_display_string(input)))
    "numbers"
    | "strings"
    | "scalars"
    | "booleans"
    | "nulls"
    | "arrays"
    | "objects"
    | "iterables" => {
      let keep = match name {
        "numbers" => input is Number(_, ..)
        "strings" => input is String(_)
        "booleans" => input is (True | False)
        "nulls" => input is Null
        "arrays" => input is Array(_)
        "objects" => input is Object(_)
        "iterables" => input is (Array(_) | Object(_))
        _ => !(input is (Array(_) | Object(_)))
      }
      if keep {
        Iter::singleton(input)
      } else {
        Iter::empty()
      }
    }
    "empty" => Iter::empty()
    "values" =>
      if input is Null {
        Iter::empty()
      } else {
        Iter::singleton(input)
      }
    "keys" | "keys_unsorted" =>
      match input {
        Object(obj) => {
          let keys = obj.keys().collect()
          if name == "keys" {
            keys.sort_by(compare_code_points)
          }
          Iter::singleton(Json::array(keys.map(Json::string)))
        }
        _ => eval_keys(input)
      }
    "contains" => Iter::singleton(Json::boolean(contains_value(input, args[0])))
    "inside" => Iter::singleton(Json::boolean(contains_value(args[0], input)))
    "has" => Iter::singleton(Json::boolean(has_value(input, args[0])))
    "in" => Iter::singleton(Json::boolean(has_value(args[0], input)))
    "indices" | "index" | "rindex" => {
      let indices = match (input, args[0]) {
        (String(s), String(needle)) => indices_of_string(s, needle)
        (Array(arr), needle) => {
          let pattern = match needle {
            Array(a) => a
            _ => [needle]
          }
          let out : Array[Json] = []
          for i in 0..<(arr.length() - pattern.length() + 1) {
            if !pattern.is_empty() && arr[i:i + pattern.length()] == pattern {
              out.push(Json::number(i.to_double()))
            }
          }
          out
        }
        _ =>
          raise TypeMismatch(
            "array/string",
            @ast_internal.json_type_name(input),
          )
      }
      Iter::singleton(
        if name == "indices" {
          Json::array(indices)
        } else if name == "index" {
          indices.get(0).unwrap_or(null)
        } else {
          indices.last().unwrap_or(null)
        },
      )
    }
    "setpath" => {
      guard args[0] is Array(path) else {
        raise InvalidOperation("Path must be specified as an array")
      }
      Iter::singleton(set_at_path(input, path, args[1]))
    }
    "delpaths" => {
      guard args[0] is Array(paths) else {
        raise InvalidOperation("Paths must be specified as an array")
      }
      let paths : Array[ArrayView[Json]] = paths.map(p => {
        match p {
          Array(a) => a
          _ => raise InvalidOperation("Path must be specified as an array")
        }
      })
      Iter::singleton(delete_paths(input, paths))
    }
    "pow" => {
      let base = if args.length() == 1 {
        numeric_arg(input)
      } else {
        numeric_arg(args[0])
      }
      let exp = numeric_arg(args[args.length() - 1])
      Iter::singleton(Json::number(@math.pow(base, exp)))
    }
    _ => raise InvalidOperation("Unknown value operation: " + name)
  }
}

///|
fn string_arg(json : Json) -> String raise PrimitiveError {
  match json {
    String(s) => s
    _ => raise TypeMismatch("string", @ast_internal.json_type_name(json))
  }
}

///|
fn numeric_arg(json : Json) -> Double raise PrimitiveError {
  match json {
    Number(n, ..) => n
    _ => raise TypeMismatch("number", @ast_internal.json_type_name(json))
  }
}

///|
fn has_value(input : Json, key : Json) -> Bool raise PrimitiveError {
  match (input, key) {
    (Null, _) => false
    (Object(obj), String(key)) => obj.contains(key)
    (Array(arr), Number(n, ..)) =>
      n >= 0 && n < arr.length().to_double() && n == n.floor()
    _ => raise InvalidOperation("Cannot check membership with these types")
  }
}

///|
fn contains_value(container : Json, item : Json) -> Bool raise PrimitiveError {
  if json_type_rank(container) != json_type_rank(item) {
    raise InvalidOperation("Cannot check containment of different types")
  }
  contains_nested(container, item)
}

///|
/// Nested type mismatches are non-matches, so array searches can continue.
fn contains_nested(container : Json, item : Json) -> Bool {
  match (container, item) {
    (String(a), String(b)) => a.contains(b)
    (Array(a), Array(b)) =>
      b.iter().all(v => a.iter().any(x => contains_nested(x, v)))
    (Object(a), Object(b)) =>
      b
      .iter()
      .all(pair => {
        a.get(pair.0).map(v => contains_nested(v, pair.1)).unwrap_or(false)
      })
    _ => container == item
  }
}
