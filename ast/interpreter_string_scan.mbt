///|
/// Evaluate Explode
fn eval_explode(input : Json) -> Iterator[Json] raise InterpreterError {
  match input {
    String(s) => {
      let results : Array[Json] = []
      for char in s {
        results.push(Json::number(char.to_int().to_double()))
      }
      Iterator::singleton(Json::array(results))
    }
    _ => raise TypeMismatch("string", json_type_name(input))
  }
}

///|
/// Evaluate Implode
fn eval_implode(input : Json) -> Iterator[Json] raise InterpreterError {
  match input {
    Array(arr) => {
      let buffer = @buffer.new()
      for elem in arr {
        match elem {
          Number(n, ..) => {
            let code = n.to_int()
            match Int::to_char(code) {
              Some(c) => buffer.write_char(c)
              None => ()
            }
          }
          _ => ()
        }
      }
      Iterator::singleton(Json::string(buffer.to_string()))
    }
    _ => raise TypeMismatch("array", json_type_name(input))
  }
}

///|
/// Evaluate Scan
fn eval_scan(
  pattern : String,
  input : Json,
) -> Iterator[Json] raise InterpreterError {
  match input {
    String(s) => {
      let results : Array[Json] = []
      let slen = s.length()
      let plen = pattern.length()
      let mut i = 0
      while i <= slen - plen {
        let slice_result = s[i:i + plen] catch {
          _ => {
            i = i + 1
            continue
          }
        }
        if slice_result.to_string() == pattern {
          results.push(Json::string(pattern))
          i = i + plen
        } else {
          i = i + 1
        }
      }
      results.iterator()
    }
    _ => raise TypeMismatch("string", json_type_name(input))
  }
}
