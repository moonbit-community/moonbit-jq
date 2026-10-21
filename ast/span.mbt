///|
/// Half-open UTF-16 offsets into the original query.
pub(all) struct Span {
  start : Int32
  end : Int32
} derive(Eq, ToJson, Debug)

///|
pub extend Span with Eq::{not_equal, equal}

///|
pub extend Span with ToJson::{to_json}

///|
pub extend Span with @debug.Debug::{to_repr}
