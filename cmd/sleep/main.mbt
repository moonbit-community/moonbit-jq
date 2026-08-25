///|
priv suberror CliError {
  CliError(String)
}

///|
fn usage() -> String {
  let message =
    #|Usage: sleep NUMBER[SUFFIX]...
    #|
    #|Pause for NUMBER seconds, like sleep(1). NUMBER may be fractional.
    #|SUFFIX may be 's' (seconds, default), 'm' (minutes), 'h' (hours), or
    #|'d' (days). With multiple arguments, sleep for their sum.
  message
}

///|
/// Parse one operand into seconds: a nonnegative (possibly fractional)
/// number with an optional s/m/h/d suffix.
fn parse_duration(text : String) -> Double raise CliError {
  let (number, multiplier) = match text {
    [.. rest, 's'] => (rest, 1.0)
    [.. rest, 'm'] => (rest, 60.0)
    [.. rest, 'h'] => (rest, 3600.0)
    [.. rest, 'd'] => (rest, 86400.0)
    _ => (text, 1.0)
  }
  // Reject a leading minus up front (so "-1e-9999" cannot underflow to an
  // accepted -0.0) and MoonBit digit separators like "1_0", which the
  // conventional sleep grammar does not allow.
  if number is ['-', ..] {
    raise CliError("sleep: invalid time interval: '\{text}'")
  }
  for c in number {
    if c == '_' {
      raise CliError("sleep: invalid time interval: '\{text}'")
    }
  }
  let value = @string.parse_double(number) catch {
    _ => raise CliError("sleep: invalid time interval: '\{text}'")
  }
  if value < 0.0 || value != value {
    raise CliError("sleep: invalid time interval: '\{text}'")
  }
  value * multiplier
}

///|
async fn main {
  let args = @env.args()[1:]
  if args.length() > 0 && (args[0] == "-h" || args[0] == "--help") {
    @stdio.stdout.write(usage() + "\n")
    return
  }
  if args.is_empty() {
    @stdio.stderr.write("sleep: missing operand\n\n" + usage() + "\n")
    @sys.exit(1)
    return
  }
  let mut seconds = 0.0
  for arg in args {
    seconds += parse_duration(arg) catch {
      CliError(msg) => {
        @stdio.stderr.write("\{msg}\n")
        @sys.exit(1)
        return
      }
    }
  }
  // @async.sleep takes milliseconds in an Int; round up so sleep never
  // waits less than requested, and clamp absurd durations.
  let ms = (seconds * 1000.0).ceil()
  let clamped = if ms > 2147483647.0 { 2147483647 } else { ms.to_int() }
  if clamped > 0 {
    @async.sleep(clamped)
  }
}
