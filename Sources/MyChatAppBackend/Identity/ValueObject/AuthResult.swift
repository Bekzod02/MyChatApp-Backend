import Foundation

/// What a successful authentication (signup or login) produces: the user's id, a freshly issued
/// access token, and when that token expires.
///
/// A natural next idea is modeling this as an enum — `.accessToken(...)` / `.activationRequired(...)`
/// — to cover outcomes like "check your email before you can log in." MyChatApp v1 has no email
/// verification step, so an enum with exactly one real case would be pure ceremony; a struct says
/// precisely what v1 actually produces, no more. If an activation flow is added later, promoting
/// this to an enum is a small, contained change, and every call site that pattern-matches on it
/// gets a compiler error pointing at exactly what needs updating — which is the actual argument
/// for waiting until there's a second real case before introducing the enum.
public struct AuthResult {
    public let userID: UUID
    public let accessToken: String
    public let expiresAt: Date

    public init(userID: UUID, accessToken: String, expiresAt: Date) {
        self.userID = userID
        self.accessToken = accessToken
        self.expiresAt = expiresAt
    }
}
