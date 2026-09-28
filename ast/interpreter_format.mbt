///|
/// Evaluate format functions: @base64, @uri, @csv, etc.
fn eval_format(
  format_name : String,
  input : Json,
) -> Iter[Json] raise InterpreterError {
  match format_name {
    "base64" =>
      match input {
        String(s) => {
          // Simple base64 encoding implementation
          let bytes = @encoding/utf8.encode(s)
          let encoded = base64_encode(bytes)
          Iter::singleton(Json::string(encoded))
        }
        _ => raise TypeError("@base64 requires string")
      }
    "base64d" =>
      match input {
        String(s) => {
          // Simple base64 decoding implementation
          let decoded_bytes = base64_decode(s) catch {
            _ => raise EvalError("Invalid base64")
          }
          let decoded_str = @encoding/utf8.decode(decoded_bytes) catch {
            _ => raise EvalError("Invalid UTF-8")
          }
          Iter::singleton(Json::string(decoded_str))
        }
        _ => raise TypeError("@base64d requires string")
      }
    "uri" =>
      match input {
        String(s) => {
          let encoded = uri_encode(s)
          Iter::singleton(Json::string(encoded))
        }
        _ => raise TypeError("@uri requires string")
      }
    "csv" | "tsv" => {
      // jq 1.7: numbers as in tojson, booleans as true/false, null as an
      // empty field; @csv always quotes strings (doubling `"`), @tsv escapes
      // \\, tab, newline and CR; arrays and objects are errors.
      guard input is Array(arr) else {
        raise TypeError("@csv/@tsv requires array")
      }
      let csv = format_name == "csv"
      let parts = arr.map(fn(item) raise InterpreterError {
        match item {
          String(s) =>
            if csv {
              "\"\{s.replace_all(old="\"", new="\"\"")}\""
            } else {
              s
              .replace_all(old="\\", new="\\\\")
              .replace_all(old="\t", new="\\t")
              .replace_all(old="\n", new="\\n")
              .replace_all(old="\r", new="\\r")
            }
          Number(_) => json_to_text(item)
          True => "true"
          False => "false"
          Null => ""
          Array(_) | Object(_) =>
            raise TypeError(
              "\{@ast_internal.json_type_name(item)} (\{json_to_text(item)}) is not valid in a csv row",
            )
        }
      })
      Iter::singleton(Json::string(parts.join(if csv { "," } else { "\t" })))
    }
    "json" => Iter::singleton(Json::string(json_to_text(input)))
    "text" => Iter::singleton(Json::string(json_to_display_string(input)))
    "html" =>
      match input {
        String(s) => {
          let escaped = html_escape(s)
          Iter::singleton(Json::string(escaped))
        }
        _ => raise TypeError("@html requires string")
      }
    _ => raise EvalError("Unknown format: @\{format_name}")
  }
}
