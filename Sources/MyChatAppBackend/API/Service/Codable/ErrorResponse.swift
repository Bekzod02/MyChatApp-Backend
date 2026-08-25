/// A uniform JSON error shape for every failed request: a stable machine-readable `code` a
/// client can switch on, plus a human-readable `message` for logging/debugging. Cross-cutting
/// (not per-module) since every controller in `API/` returns this same shape.
struct ErrorResponse: Encodable {
    let code: String
    let message: String
}
