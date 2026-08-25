import Foundation

/// What `signup`/`login` return over the wire. Built from `AuthResult` rather than making
/// `AuthResult` itself `Encodable` — keeping `Identity/` free of any dependency on "how this gets
/// serialized for HTTP" is exactly the module-boundary discipline §2.1 describes, just showing up
/// here as a small, concrete translation step instead of an abstract rule.
struct AuthResponse: Encodable {
    let userId: UUID
    let accessToken: String
    let expiresAt: Date

    init(_ result: AuthResult) {
        userId = result.userID
        accessToken = result.accessToken
        expiresAt = result.expiresAt
    }
}
