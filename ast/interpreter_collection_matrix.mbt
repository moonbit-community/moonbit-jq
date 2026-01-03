///|
/// Evaluate Combinations
fn eval_combinations(input : Json) -> Iterator[Json] raise InterpreterError {
  match input {
    Array(arr) => {
      let arrays : Array[Array[Json]] = []
      for elem in arr {
        match elem {
          Array(inner) => arrays.push(inner)
          _ => return Iterator::empty()
        }
      }
      if arrays.is_empty() {
        return Iterator::empty()
      }
      let mut results : Array[Array[Json]] = [[]]
      for arr_item in arrays {
        let new_results : Array[Array[Json]] = []
        for res in results {
          for item in arr_item {
            let new_res = res.copy()
            new_res.push(item)
            new_results.push(new_res)
          }
        }
        results = new_results
      }
      results.iterator().map(Json::array)
    }
    _ => raise TypeMismatch("array", json_type_name(input))
  }
}

///|
/// Evaluate Transpose
fn eval_transpose(input : Json) -> Iterator[Json] raise InterpreterError {
  match input {
    Array(arr) => {
      let mut max_len = 0
      for elem in arr {
        match elem {
          Array(inner) =>
            if inner.length() > max_len {
              max_len = inner.length()
            }
          _ => ()
        }
      }
      let results : Array[Array[Json]] = []
      for col = 0; col < max_len; col = col + 1 {
        let row : Array[Json] = []
        for elem in arr {
          match elem {
            Array(inner) => if col < inner.length() { row.push(inner[col]) }
            _ => ()
          }
        }
        results.push(row)
      }
      Iterator::singleton(Json::array(results.map(Json::array)))
    }
    _ => raise TypeMismatch("array", json_type_name(input))
  }
}
