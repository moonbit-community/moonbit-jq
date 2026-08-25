///|
fn uniq_command() -> @argparse.Command {
  Command(
    "uniq",
    about="Filter adjacent repeated lines.",
    flags=[
      FlagArg("count", short='c', about="Prefix lines with occurrence counts."),
      FlagArg("repeated", short='d', about="Only print lines that repeat."),
      FlagArg("unique", short='u', about="Only print lines that do not repeat."),
      FlagArg("ignore-case", short='i', about="Compare case-insensitively."),
    ],
    positionals=[
      PositionArg(
        "input",
        about="[file] ('-' or no file reads stdin)",
        num_args=ValueRange(lower=0, upper=1),
      ),
    ],
    disable_help_subcommand=true,
  )
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
fn pad_left(text : String, width : Int) -> String {
  let sb = StringBuilder()
  for _ in 0..<(width - text.length()) {
    sb.write_char(' ')
  }
  sb.write_string(text)
  sb.to_string()
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
  let command = uniq_command()
  let matches = command.parse(argv=args, env=Map([])) catch {
    err => {
      @stdio.stderr.write("\{err}\n")
      @sys.exit(2)
      return
    }
  }
  let show_count = matches.flags.get_or_default("count", false)
  let only_repeated = matches.flags.get_or_default("repeated", false)
  let only_unique = matches.flags.get_or_default("unique", false)
  let ignore_case = matches.flags.get_or_default("ignore-case", false)
  let inputs = matches.values.get("input").unwrap_or([])
  let path = if inputs.is_empty() { "-" } else { inputs[0] }
  let text = read_source_text(path) catch {
    err => {
      @stdio.stderr.write("uniq: \{err}\n")
      @sys.exit(1)
      return
    }
  }
  let lines = split_lines(text)
  // Each group is the first line of an adjacent run plus its length.
  let groups : Array[(String, Int)] = []
  for line in lines {
    let key = if ignore_case { line.to_lower() } else { line }
    if groups.length() > 0 {
      let (last, count) = groups[groups.length() - 1]
      let last_key = if ignore_case { last.to_lower() } else { last }
      if last_key == key {
        groups[groups.length() - 1] = (last, count + 1)
        continue
      }
    }
    groups.push((line, 1))
  }
  for group in groups {
    let (line, count) = group
    let selected = if only_repeated && only_unique {
      false
    } else if only_repeated {
      count > 1
    } else if only_unique {
      count == 1
    } else {
      true
    }
    if selected {
      if show_count {
        @stdio.stdout.write(pad_left(count.to_string(), 7) + " " + line + "\n")
      } else {
        @stdio.stdout.write(line + "\n")
      }
    }
  }
}
