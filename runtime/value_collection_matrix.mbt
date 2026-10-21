///|
/// Evaluate Transpose
fn eval_transpose(input : Json) -> Iter[Json] raise PrimitiveError {
  match input {
    Array(arr) => {
      let max_len = max_row_len(arr)
      let rows = build_columns(arr, max_len)
      Iter::singleton(Json::array(rows.map(Json::array)))
    }
    _ => raise TypeMismatch("array", @ast_internal.json_type_name(input))
  }
}

///|
fn max_row_len(rows : ArrayView[Json]) -> Int32 {
  rows.fold(init=0, fn(max_len, row) {
    match row {
      Array(inner) => @cmp.maximum(max_len, inner.length())
      _ => max_len
    }
  })
}

///|
fn build_columns(rows : ArrayView[Json], max_len : Int32) -> Array[Array[Json]] {
  let columns : Array[Array[Json]] = []
  for col in 0..<max_len {
    let column : Array[Json] = []
    for row in rows {
      match row {
        Array(inner) => if col < inner.length() { column.push(inner[col]) }
        _ => ()
      }
    }
    columns.push(column)
  }
  columns
}
