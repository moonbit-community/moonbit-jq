name = "bobzhang/comm"

version = "0.1.1"

readme = "README.md"

repository = "https://github.com/moonbit-community/moonbit-jq"

license = "Apache-2.0"

keywords = [ "comm", "coreutils", "text", "cli", "wasm" ]

description = "Compare two sorted files line by line like comm, runnable via moonx"

import {
  "moonbitlang/async@0.21.1",
  "moonbitlang/x@0.5.1",
}

preferred_target = "wasm"

warnings = "+test_unqualified_package+unnecessary_view_op+unnecessary_annotation+deprecated+missing_doc"
