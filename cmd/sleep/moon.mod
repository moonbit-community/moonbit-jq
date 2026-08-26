name = "bobzhang/sleep"

version = "0.1.1"

readme = "README.md"

repository = "https://github.com/moonbit-community/moonbit-jq"

license = "Apache-2.0"

keywords = [ "sleep", "coreutils", "timer", "cli", "wasm" ]

description = "Pause for a number of seconds, like sleep, runnable via moonx"

import {
  "moonbitlang/async@0.21.1",
  "moonbitlang/x@0.5.1",
}

preferred_target = "wasm"

warnings = "+test_unqualified_package+unnecessary_view_op+unnecessary_annotation+deprecated+missing_doc"
