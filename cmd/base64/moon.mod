name = "bobzhang/base64"

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/moonbit-community/moonbit-jq"

license = "Apache-2.0"

keywords = [ "base64", "coreutils", "encoding", "cli", "wasm" ]

description = "Base64 encode and decode like base64, runnable via moonx"

import {
  "moonbitlang/async@0.21.0",
  "moonbitlang/x@0.5.1",
}

preferred_target = "wasm"

warnings = "+test_unqualified_package+unnecessary_view_op+unnecessary_annotation+deprecated+missing_doc"
