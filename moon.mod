name = "moonbit-community/moonjq"

version = "0.2.0"

readme = "README.mbt.md"

repository = "https://github.com/moonbit-community/moonbit-jq"

keywords = [ "jq", "json", "query" ]

description = "A jq implementation in MoonBit"

import {
  "moonbitlang/async@0.22.4",
  "moonbitlang/x@0.5.1",
}

preferred_target = "native"

license = "Apache-2.0"

warnings = "+test_unqualified_package+unnecessary_view_op+unnecessary_annotation+deprecated+missing_doc"
