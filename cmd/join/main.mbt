///|
fn help_message() -> String {
  let message =
    #|Usage: join [options] FILE1 FILE2
    #|
    #|Join lines of two files sorted on their join fields.
    #|Only pairable lines are printed (no -a support yet).
    #|
    #|Options:
    #|  -1 FIELD    Join on this field of FILE1 (default 1).
    #|  -2 FIELD    Join on this field of FILE2 (default 1).
    #|  -t CHAR     Use CHAR as the field separator instead of runs of
    #|              blanks; the output separator becomes CHAR as well.
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
fn split_fields(line : String, separator : String?) -> Array[String] {
  match separator {
    Some(sep) => line.split(sep).map(v => v.to_owned()).collect()
    None => {
      let fields : Array[String] = []
      let sb = StringBuilder()
      let mut in_field = false
      for c in line {
        if c == ' ' || c == '\t' {
          if in_field {
            fields.push(sb.to_string())
            sb.reset()
            in_field = false
          }
        } else {
          sb.write_char(c)
          in_field = true
        }
      }
      if in_field {
        fields.push(sb.to_string())
      }
      fields
    }
  }
}

///|
fn key_of(fields : Array[String], field : Int) -> String {
  if field - 1 < fields.length() {
    fields[field - 1]
  } else {
    ""
  }
}

///|
fn rest_of(fields : Array[String], field : Int) -> Array[String] {
  let rest : Array[String] = []
  for index, value in fields {
    if index != field - 1 {
      rest.push(value)
    }
  }
  rest
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
  let mut field1 = 1
  let mut field2 = 1
  let mut separator : String? = None
  let files : Array[String] = []
  let mut index = 0
  while index < args.length() {
    let arg = args[index]
    if arg == "-h" || arg == "--help" {
      @stdio.stdout.write(help_message() + "\n")
      return
    }
    if arg.has_prefix("-1") || arg.has_prefix("-2") || arg.has_prefix("-t") {
      let is_separator = arg.has_prefix("-t")
      // Accept both `-t,` (attached value) and `-t ,` (separate argument).
      let (value, consumed) = if arg.length() > 2 {
        (arg[2:].to_owned(), 1)
      } else if index + 1 < args.length() {
        (args[index + 1], 2)
      } else {
        @stdio.stderr.write("join: missing value after '\{arg}'\n")
        @sys.exit(2)
        return
      }
      if is_separator {
        if value.char_length() != 1 {
          @stdio.stderr.write(
            "join: the separator must be a single character\n",
          )
          @sys.exit(2)
          return
        }
        separator = Some(value)
      } else {
        let n = @string.parse_int(value) catch {
          _ => {
            @stdio.stderr.write("join: invalid field number: '\{value}'\n")
            @sys.exit(2)
            return
          }
        }
        if n < 1 {
          @stdio.stderr.write("join: invalid field number: '\{value}'\n")
          @sys.exit(2)
          return
        }
        if arg.has_prefix("-1") {
          field1 = n
        } else {
          field2 = n
        }
      }
      index += consumed
      continue
    }
    if arg.has_prefix("-") && arg != "-" {
      @stdio.stderr.write("join: unknown option: '\{arg}'\n")
      @sys.exit(2)
      return
    }
    files.push(arg)
    index += 1
  }
  if files.length() != 2 {
    @stdio.stderr.write(
      "join: expected exactly two files\n\n" + help_message() + "\n",
    )
    @sys.exit(2)
    return
  }
  let (lines1, lines2) = (
    split_lines(read_source_text(files[0])),
    split_lines(read_source_text(files[1])),
  ) catch {
    err => {
      @stdio.stderr.write("join: \{err}\n")
      @sys.exit(1)
      return
    }
  }
  let fields1 : Array[Array[String]] = lines1.map(l => {
    split_fields(l, separator)
  })
  let fields2 : Array[Array[String]] = lines2.map(l => {
    split_fields(l, separator)
  })
  let out_sep = match separator {
    Some(sep) => sep
    None => " "
  }
  let mut i = 0
  let mut j = 0
  while i < fields1.length() && j < fields2.length() {
    let key1 = key_of(fields1[i], field1)
    let key2 = key_of(fields2[j], field2)
    let cmp = key1.compare(key2)
    if cmp < 0 {
      i += 1
    } else if cmp > 0 {
      j += 1
    } else {
      // Find the runs of equal keys in both inputs and emit their product.
      let mut end1 = i
      while end1 < fields1.length() && key_of(fields1[end1], field1) == key1 {
        end1 += 1
      }
      let mut end2 = j
      while end2 < fields2.length() && key_of(fields2[end2], field2) == key2 {
        end2 += 1
      }
      for a in i..<end1 {
        for b in j..<end2 {
          let parts : Array[String] = [key1]
          parts.append(rest_of(fields1[a], field1))
          parts.append(rest_of(fields2[b], field2))
          @stdio.stdout.write(parts.join(out_sep) + "\n")
        }
      }
      i = end1
      j = end2
    }
  }
}
