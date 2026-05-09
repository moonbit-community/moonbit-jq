///|
fn keep_imports_used() -> Unit {
  // The shared package imports are used by main_native.mbt.
  ignore(@moonjq.parse)
  ignore(@async.now)
  ignore(@io.pipe)
  ignore(@stdio.unimplemented)
  ignore(@json.valid)
  ignore(@fs.path_exists)
  ignore(@sys.get_cli_args)
}

///|
fn main {
  keep_imports_used()
  println("moonjq log CLI is only supported on native targets.")
}
