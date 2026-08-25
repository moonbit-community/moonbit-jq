///|
fn help_message() -> String {
  let message =
    #|Usage: comm [-123] FILE1 FILE2
    #|
    #|Compare two sorted files line by line, producing three columns:
    #|lines only in FILE1, lines only in FILE2, and lines in both.
    #|
    #|Options:
    #|  -1  Suppress column 1 (lines unique to FILE1).
    #|  -2  Suppress column 2 (lines unique to FILE2).
    #|  -3  Suppress column 3 (lines in both files).
    #|  -h, --help  Show this help message.
    #|
    #|Use '-' as a file name to read stdin.
  message
}

///|
fn split_lines(text : String) -> Array[String] {
  if text is "" {
    return []
  }
  let lines : Array[String] = text.split("\n").map(v => v.to_owned()).collect()
  if text.has_suffix("\n") {
    ignore(lines.pop())
  }
  lines
}

///|
async fn read_source_text(path : String) -> String {
  if path == "-" {
    @stdio.stdin.read_all().text()
  } else {
    @fs.read_file_to_string(path)
  }
}

///|
async fn main {
  let args = @env.args()[1:]
  let mut hide1 = false
  let mut hide2 = false
  let mut hide3 = false
  let files : Array[String] = []
  for arg in args {
    if arg == "-h" || arg == "--help" {
      @stdio.stdout.write(help_message() + "\n")
      return
    }
    if arg.has_prefix("-") && arg != "-" {
      for i in 1..<arg.length() {
        match arg[i] {
          '1' => hide1 = true
          '2' => hide2 = true
          '3' => hide3 = true
          _ => {
            @stdio.stderr.write("comm: unknown option: '\{arg}'\n")
            @sys.exit(2)
            return
          }
        }
      }
    } else {
      files.push(arg)
    }
  }
  if files.length() != 2 {
    @stdio.stderr.write(
      "comm: expected exactly two files\n\n" + help_message() + "\n",
    )
    @sys.exit(2)
    return
  }
  let (lines1, lines2) = (
    split_lines(read_source_text(files[0])),
    split_lines(read_source_text(files[1])),
  ) catch {
    err => {
      @stdio.stderr.write("comm: \{err}\n")
      @sys.exit(1)
      return
    }
  }
  let col2_prefix = if hide1 { "" } else { "\t" }
  let col3_prefix = (if hide1 { "" } else { "\t" }) +
    (if hide2 { "" } else { "\t" })
  let mut i = 0
  let mut j = 0
  while i < lines1.length() && j < lines2.length() {
    let cmp = lines1[i].compare(lines2[j])
    if cmp < 0 {
      if !hide1 {
        @stdio.stdout.write(lines1[i] + "\n")
      }
      i += 1
    } else if cmp > 0 {
      if !hide2 {
        @stdio.stdout.write(col2_prefix + lines2[j] + "\n")
      }
      j += 1
    } else {
      if !hide3 {
        @stdio.stdout.write(col3_prefix + lines1[i] + "\n")
      }
      i += 1
      j += 1
    }
  }
  while i < lines1.length() {
    if !hide1 {
      @stdio.stdout.write(lines1[i] + "\n")
    }
    i += 1
  }
  while j < lines2.length() {
    if !hide2 {
      @stdio.stdout.write(col2_prefix + lines2[j] + "\n")
    }
    j += 1
  }
}
