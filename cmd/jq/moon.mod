name = "bobzhang/jq"

version = "0.1.1"

readme = "README.md"

repository = "https://github.com/moonbit-community/moonbit-jq"

license = "Apache-2.0"

keywords = [ "jq", "json", "query", "cli", "wasm" ]

description = "Run jq-compatible JSON filters directly with moonx"

import {
  "bobzhang/moonjq@0.1.1",
  "moonbitlang/async@0.21.0",
  "moonbitlang/x@0.5.1",
}

preferred_target = "wasm"

warnings = "+test_unqualified_package+unnecessary_view_op+unnecessary_annotation+deprecated+missing_doc"
