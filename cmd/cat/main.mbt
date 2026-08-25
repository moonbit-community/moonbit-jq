///|
fn help_message() -> String {
  let message =
    #|Usage: cat [FILE...]
    #|
    #|Concatenate FILEs (or stdin) to standard output, byte-transparently:
    #|no decoding, no newline normalization. Use '-' or no file for stdin.
    #|
    #|  -h, --help  Show this help message.
  message
}

///|
async fn main {
  let args = @env.args()[1:]
  if args.length() > 0 && (args[0] == "-h" || args[0] == "--help") {
    @stdio.stdout.write(help_message() + "\n")
    return
  }
  // A leading `--` ends option processing, so `cat -- -h` reads a file
  // literally named -h.
  let operands = if args.length() > 0 && args[0] == "--" {
    args[1:]
  } else {
    args
  }
  let sources = if operands.is_empty() { ["-"][:] } else { operands }
  let mut failed = false
  for path in sources {
    try {
      if path == "-" {
        @stdio.stdout.write_reader(@stdio.stdin)
      } else {
        let file = @fs.open(path, mode=ReadOnly)
        defer file.close()
        @stdio.stdout.write_reader(file)
      }
    } catch {
      err => {
        @stdio.stderr.write("cat: \{err}\n")
        failed = true
      }
    }
  }
  if failed {
    @sys.exit(1)
  }
}
