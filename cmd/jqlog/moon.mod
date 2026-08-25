name = "bobzhang/jqlog"

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/moonbit-community/moonbit-jq"

license = "Apache-2.0"

keywords = [ "jq", "json", "jsonl", "logs", "cli" ]

description = "Run jq-compatible filters over JSON Lines input"

import {
  "bobzhang/moonjq@0.1.1",
  "moonbitlang/async@0.21.0",
  "moonbitlang/x@0.5.1",
}

preferred_target = "native"

warnings = "+test_unqualified_package+unnecessary_view_op+unnecessary_annotation+deprecated+missing_doc"
