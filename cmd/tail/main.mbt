///|
priv suberror CliError {
  CliError(String)
}

///|
/// `Last(n)` selects the final n units; `FromStart(k)` selects from the k-th
/// unit (1-based) to the end, mirroring tail's `-n +K` syntax.
priv enum CountSpec {
  Last(Int64)
  FromStart(Int64)
}

///|
let chunk_size : Int = 65536

///|
fn tail_command() -> @argparse.Command {
  Command(
    "tail",
    about="Print the last lines (or bytes) of each input.",
    flags=[
      FlagArg("quiet", short='q', about="Never print file name headers."),
      FlagArg("verbose", short='v', about="Always print file name headers."),
    ],
    options=[
      OptionArg(
        "lines",
        short='n',
        about="Print the last N lines, or from line +N (default 10).",
        allow_hyphen_values=true,
      ),
      OptionArg(
        "bytes",
        short='c',
        about="Print the last N bytes, or from byte +N.",
        conflicts_with=["lines"],
      ),
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
fn option_value(matches : @argparse.Matches, name : String) -> String? {
  match matches.values.get(name) {
    Some(vals) =>
      if vals.is_empty() {
        None
      } else {
        Some(vals[vals.length() - 1])
      }
    None => None
  }
}

///|
fn parse_spec(text : String) -> CountSpec raise CliError {
  let (from_start, digits) = if text is ['+', .. rest] {
    (true, rest)
  } else {
    (false, text)
  }
  let n = @string.parse_int64(digits) catch {
    _ => raise CliError("tail: invalid count: '\{text}'")
  }
  if n < 0 {
    raise CliError("tail: invalid count: '\{text}'")
  }
  if from_start {
    FromStart(if n < 1 { 1 } else { n })
  } else {
    Last(n)
  }
}

///|
/// Select lines from an in-memory buffer (used for streamed input after the
/// ring buffer has trimmed it down). A trailing newline terminates the final
/// line rather than starting an empty one.
fn select_lines(data : Bytes, spec : CountSpec) -> BytesView {
  match spec {
    Last(n) => {
      if n <= 0 || data.length() == 0 {
        return data[0:0]
      }
      let mut i = if data[data.length() - 1] is b'\n' {
        data.length() - 2
      } else {
        data.length() - 1
      }
      let mut newlines : Int64 = 0
      while i >= 0 {
        if data[i] is b'\n' {
          newlines += 1
          if newlines == n {
            return data[i + 1:]
          }
        }
        i -= 1
      }
      data
    }
    FromStart(k) => {
      if k <= 1 {
        return data
      }
      let mut seen : Int64 = 0
      for i in 0..<data.length() {
        if data[i] is b'\n' {
          seen += 1
          if seen == k - 1 {
            return data[i + 1:]
          }
        }
      }
      data[data.length():]
    }
  }
}

///|
fn select_bytes(data : Bytes, spec : CountSpec) -> BytesView {
  let len = data.length().to_int64()
  match spec {
    Last(n) => {
      let start = if n >= len { 0 } else { (len - n).to_int() }
      data[start:]
    }
    FromStart(k) => {
      let start = if k - 1 > len { data.length() } else { (k - 1).to_int() }
      data[start:]
    }
  }
}

///|
fn count_newlines(chunk : Bytes) -> Int {
  let mut n = 0
  for b in chunk {
    if b is b'\n' {
      n += 1
    }
  }
  n
}

///|
fn concat_chunks(chunks : Array[Bytes]) -> Bytes {
  let out : Array[Byte] = []
  for chunk in chunks {
    for b in chunk {
      out.push(b)
    }
  }
  Bytes::from_array(out)
}

///|
/// Stream file bytes in [start, end) to stdout in fixed-size chunks.
async fn stream_range(file : @fs.File, start : Int64, end : Int64) -> Unit {
  let mut pos = start
  while pos < end {
    let len = if end - pos < chunk_size.to_int64() {
      (end - pos).to_int()
    } else {
      chunk_size
    }
    @stdio.stdout.write(file.read_exactly_at(len, position=pos))
    pos += len.to_int64()
  }
}

///|
/// GNU-style tail for seekable files: find the start of the selection by
/// scanning backward (or forward for +K) in fixed-size chunks, then stream
/// it out. Memory stays bounded by the chunk size for any file size.
async fn tail_file(
  file : @fs.File,
  spec : CountSpec,
  bytes_mode : Bool,
) -> Unit {
  let size = file.size()
  if bytes_mode {
    let start : Int64 = match spec {
      Last(n) => if n >= size { 0 } else { size - n }
      FromStart(k) => if k - 1 > size { size } else { k - 1 }
    }
    stream_range(file, start, size)
    return
  }
  match spec {
    Last(n) => {
      if n <= 0 || size == 0 {
        return
      }
      let mut newlines : Int64 = 0
      let mut start : Int64 = 0
      let mut found = false
      let mut pos = size
      let mut at_file_end = true
      while pos > 0 && !found {
        let len = if pos < chunk_size.to_int64() {
          pos.to_int()
        } else {
          chunk_size
        }
        let chunk = file.read_exactly_at(len, position=pos - len.to_int64())
        let mut idx = chunk.length() - 1
        if at_file_end && chunk[idx] is b'\n' {
          // The trailing newline terminates the last line rather than
          // starting an empty one.
          idx -= 1
        }
        at_file_end = false
        while idx >= 0 {
          if chunk[idx] is b'\n' {
            newlines += 1
            if newlines == n {
              start = pos - len.to_int64() + idx.to_int64() + 1
              found = true
              break
            }
          }
          idx -= 1
        }
        pos -= len.to_int64()
      }
      stream_range(file, start, size)
    }
    FromStart(k) => {
      if k <= 1 {
        stream_range(file, 0, size)
        return
      }
      // Scan forward for the (k-1)-th newline, then stream the rest.
      let mut seen : Int64 = 0
      let mut pos : Int64 = 0
      while pos < size {
        let len = if size - pos < chunk_size.to_int64() {
          (size - pos).to_int()
        } else {
          chunk_size
        }
        let chunk = file.read_exactly_at(len, position=pos)
        for i in 0..<chunk.length() {
          if chunk[i] is b'\n' {
            seen += 1
            if seen == k - 1 {
              stream_range(file, pos + i.to_int64() + 1, size)
              return
            }
          }
        }
        pos += len.to_int64()
      }
    }
  }
}

///|
async fn read_chunk(r : &@io.Reader, buf : FixedArray[Byte]) -> Bytes? {
  let n = r.read(buf)
  if n == 0 {
    None
  } else {
    Some(Bytes::from_array(buf[0:n]))
  }
}

///|
/// Tail an unseekable stream (stdin, pipes). `Last` keeps a ring of chunks
/// holding just the bytes of the selection, so memory is bounded by the
/// output size plus one chunk; `FromStart` writes through once the start
/// point has passed, buffering nothing.
async fn tail_stream(
  r : &@io.Reader,
  spec : CountSpec,
  bytes_mode : Bool,
) -> Unit {
  let buf : FixedArray[Byte] = FixedArray::make(chunk_size, 0)
  match spec {
    Last(n) => {
      if n <= 0 {
        // Drain the input like GNU tail, producing no output.
        while true {
          if read_chunk(r, buf) is None {
            break
          }
        }
        return
      }
      let chunks : Array[Bytes] = []
      let counts : Array[Int64] = []
      let mut total_newlines : Int64 = 0
      let mut total_bytes : Int64 = 0
      for ;; {
        match read_chunk(r, buf) {
          Some(chunk) => {
            chunks.push(chunk)
            total_bytes += chunk.length().to_int64()
            if bytes_mode {
              while chunks.length() > 1 &&
                    total_bytes - chunks[0].length().to_int64() >= n {
                total_bytes -= chunks[0].length().to_int64()
                ignore(chunks.remove(0))
              }
            } else {
              let c = count_newlines(chunk).to_int64()
              counts.push(c)
              total_newlines += c
              // Keep more than n newlines beyond the dropped prefix so the
              // last n lines stay fully buffered. (Written as `> n` rather
              // than `>= n + 1`, which would overflow for n = INT64_MAX.)
              while chunks.length() > 1 && total_newlines - counts[0] > n {
                total_newlines -= counts[0]
                ignore(chunks.remove(0))
                ignore(counts.remove(0))
              }
            }
          }
          None => break
        }
      }
      let data = concat_chunks(chunks)
      if bytes_mode {
        @stdio.stdout.write(select_bytes(data, spec))
      } else {
        @stdio.stdout.write(select_lines(data, spec))
      }
    }
    FromStart(k) =>
      if bytes_mode {
        let mut to_skip : Int64 = if k > 1 { k - 1 } else { 0 }
        for ;; {
          match read_chunk(r, buf) {
            Some(chunk) =>
              if to_skip >= chunk.length().to_int64() {
                to_skip -= chunk.length().to_int64()
              } else if to_skip > 0 {
                @stdio.stdout.write(chunk[to_skip.to_int():])
                to_skip = 0
              } else {
                @stdio.stdout.write(chunk)
              }
            None => break
          }
        }
      } else {
        let mut remaining : Int64 = if k > 1 { k - 1 } else { 0 }
        for ;; {
          match read_chunk(r, buf) {
            Some(chunk) => {
              if remaining == 0 {
                @stdio.stdout.write(chunk)
                continue
              }
              let mut emitted = false
              for i in 0..<chunk.length() {
                if chunk[i] is b'\n' {
                  remaining -= 1
                  if remaining == 0 {
                    @stdio.stdout.write(chunk[i + 1:])
                    emitted = true
                    break
                  }
                }
              }
              ignore(emitted)
            }
            None => break
          }
        }
      }
  }
}

///|
async fn main {
  let args = @env.args()[1:]
  let command = tail_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let quiet = matches.flags.get_or_default("quiet", false)
  let verbose = matches.flags.get_or_default("verbose", false)
  let (spec, bytes_mode) = try {
    match option_value(matches, "bytes") {
      Some(text) => (parse_spec(text), true)
      None =>
        match option_value(matches, "lines") {
          Some(text) => (parse_spec(text), false)
          None => (Last(10), false)
        }
    }
  } catch {
    CliError(msg) => {
      @stdio.stderr.write("\{msg}\n")
      @sys.exit(2)
      return
    }
  }
  let files = matches.values.get("files").unwrap_or([])
  let sources = if files.is_empty() { ["-"] } else { files }
  let show_headers = (sources.length() > 1 || verbose) && !quiet
  let mut failed = false
  for index, path in sources {
    if show_headers {
      let name = if path == "-" { "standard input" } else { path }
      let prefix = if index > 0 { "\n" } else { "" }
      @stdio.stdout.write("\{prefix}==> \{name} <==\n")
    }
    try {
      if path == "-" {
        tail_stream(@stdio.stdin, spec, bytes_mode)
      } else {
        let file = @fs.open(path, mode=ReadOnly)
        defer file.close()
        if file.kind() is Regular {
          tail_file(file, spec, bytes_mode)
        } else {
          // Named pipes and devices are not seekable; stream them instead.
          tail_stream(file, spec, bytes_mode)
        }
      }
    } catch {
      err => {
        @stdio.stderr.write("tail: \{err}\n")
        failed = true
      }
    }
  }
  if failed {
    @sys.exit(1)
  }
}
