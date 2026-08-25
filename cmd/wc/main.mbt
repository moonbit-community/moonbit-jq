///|
priv struct Counts {
  mut lines : Int64
  mut words : Int64
  mut chars : Int64
  mut bytes : Int64
}

///|
fn Counts::new() -> Counts {
  { lines: 0, words: 0, chars: 0, bytes: 0 }
}

///|
fn Counts::add(self : Counts, other : Counts) -> Unit {
  self.lines += other.lines
  self.words += other.words
  self.chars += other.chars
  self.bytes += other.bytes
}

///|
fn is_space_byte(b : Byte) -> Bool {
  b is (b' ' | b'\t' | b'\n' | b'\r' | 0x0B | 0x0C)
}

///|
fn count(data : Bytes) -> Counts {
  let counts = Counts::new()
  counts.bytes = data.length().to_int64()
  let mut in_word = false
  for b in data {
    if b is b'\n' {
      counts.lines += 1
    }
    // UTF-8 continuation bytes are 0b10xxxxxx; everything else starts a char.
    if (b.to_int() & 0xC0) != 0x80 {
      counts.chars += 1
    }
    if is_space_byte(b) {
      in_word = false
    } else if !in_word {
      in_word = true
      counts.words += 1
    }
  }
  counts
}

///|
priv struct Selection {
  lines : Bool
  words : Bool
  chars : Bool
  bytes : Bool
}

///|
fn render_counts(
  counts : Counts,
  selection : Selection,
  name : String?,
) -> String {
  let parts : Array[String] = []
  if selection.lines {
    parts.push(counts.lines.to_string())
  }
  if selection.words {
    parts.push(counts.words.to_string())
  }
  if selection.chars {
    parts.push(counts.chars.to_string())
  }
  if selection.bytes {
    parts.push(counts.bytes.to_string())
  }
  if name is Some(n) {
    parts.push(n)
  }
  parts.join(" ")
}

///|
fn wc_command() -> @argparse.Command {
  Command(
    "wc",
    about="Count lines, words, and bytes for each input.",
    flags=[
      FlagArg("lines", short='l', about="Print newline counts."),
      FlagArg("words", short='w', about="Print word counts."),
      FlagArg("bytes", short='c', about="Print byte counts."),
      FlagArg("chars", short='m', about="Print character (UTF-8) counts."),
    ],
    positionals=[
      PositionArg(
        "files",
        about="[file...] ('-' or no file reads stdin)",
        num_args=ValueRange(lower=0),
      ),
    ],
    disable_help_subcommand=true,
  )
}

///|
async fn read_source(path : String) -> Bytes {
  if path == "-" {
    @stdio.stdin.read_all().binary()
  } else {
    @fs.read_file_to_bytes(path)
  }
}

///|
async fn main {
  let args = @env.args()[1:]
  let command = wc_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let lines = matches.flags.get_or_default("lines", false)
  let words = matches.flags.get_or_default("words", false)
  let chars = matches.flags.get_or_default("chars", false)
  let bytes = matches.flags.get_or_default("bytes", false)
  let selection : Selection = if lines || words || chars || bytes {
    { lines, words, chars, bytes }
  } else {
    { lines: true, words: true, chars: false, bytes: true }
  }
  let files = matches.values.get("files").unwrap_or([])
  let total = Counts::new()
  let mut failed = false
  if files.is_empty() {
    let counts = count(@stdio.stdin.read_all().binary())
    @stdio.stdout.write(render_counts(counts, selection, None) + "\n")
  } else {
    for path in files {
      let data = read_source(path) catch {
        err => {
          @stdio.stderr.write("wc: \{err}\n")
          failed = true
          continue
        }
      }
      let counts = count(data)
      total.add(counts)
      @stdio.stdout.write(render_counts(counts, selection, Some(path)) + "\n")
    }
    if files.length() > 1 {
      @stdio.stdout.write(render_counts(total, selection, Some("total")) + "\n")
    }
  }
  if failed {
    @sys.exit(1)
  }
}
