name = "bobzhang/moonjq"

version = "0.1.1"

readme = "README.mbt.md"

repository = "git@github.com:moonbit-community/moobit-jq.git"

keywords = [ "jq", "json", "query" ]

description = "A jq implementation in MoonBit"

import {
  "moonbitlang/async@0.21.0",
  "moonbitlang/x@0.5.1",
}

preferred_target = "native"

license = "Apache-2.0"

warnings = "+test_unqualified_package+unnecessary_view_op+unnecessary_annotation+deprecated+missing_doc"
