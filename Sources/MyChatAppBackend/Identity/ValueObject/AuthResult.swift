import Foundation

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
