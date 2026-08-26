import Chaqmoq
import Foundation

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
