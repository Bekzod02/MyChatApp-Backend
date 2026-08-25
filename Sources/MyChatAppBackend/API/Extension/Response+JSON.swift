import Chaqmoq
import Foundation

/// A single, shared way to turn any `Encodable` value into a JSON HTTP response — every
/// controller in `API/` goes through this instead of hand-rolling `JSONEncoder` + headers at
/// each call site. DRY applied to plumbing, not business logic: the `Content-Type` header and
/// date-encoding strategy only need to be decided once, in one place.
extension Response {
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static func json<T: Encodable>(_ value: T, status: Status = .ok) throws -> Response {
        Response(
            try jsonEncoder.encode(value),
            status: status,
            headers: Headers([.contentType: "application/json"])
        )
    }
}
