///|
fn eval_expr(expr : @ast.Expr, input : String) -> Array[Json] raise {
  let json_input = @json.parse(input)
  @ast.eval(expr, json_input).collect()
}

///|
test "coverage: eval functiondef and path expr" {
  let fn_expr : @ast.Expr = FunctionDef("f", [], Identity)
  json_inspect(eval_expr(fn_expr, "1"), content=[1])
  let path_expr : @ast.Expr = Path(Identity)
  json_inspect(eval_expr(path_expr, "{\"a\":1}"), content=[[]])
}

///|
test "coverage: update with index left branches" {
  let update_expr : @ast.Expr = Literal(Number(1.0))
  let path_valid : @ast.Expr = Pipe(Index([0]), Key("a"))
  let expr_valid : @ast.Expr = Update(path_valid, update_expr)
  json_inspect(eval_expr(expr_valid, "[{\"a\":0}]"), content=[[{ "a": 1 }]])
  let path_empty : @ast.Expr = Pipe(Index([]), Key("a"))
  let expr_empty : @ast.Expr = Update(path_empty, update_expr)
  json_inspect(eval_expr(expr_empty, "[{\"a\":0}]"), content=[[{ "a": 0 }]])
  let path_oob : @ast.Expr = Pipe(Index([5]), Key("a"))
  let expr_oob : @ast.Expr = Update(path_oob, update_expr)
  json_inspect(eval_expr(expr_oob, "[{\"a\":0}]"), content=[[{ "a": 0 }]])
  let expr_non_array : @ast.Expr = Update(path_valid, update_expr)
  json_inspect(eval_expr(expr_non_array, "1"), content=[1])
}

///|
test "coverage: update with complex left pipe" {
  let path : @ast.Expr = Pipe(Pipe(Key("a"), Key("b")), Key("c"))
  let update_expr : @ast.Expr = Literal(Number(2.0))
  let expr : @ast.Expr = Update(path, update_expr)
  json_inspect(eval_expr(expr, "{\"a\":{\"b\":{\"c\":1}}}"), content=[
    { "c": 2 },
  ])
}
