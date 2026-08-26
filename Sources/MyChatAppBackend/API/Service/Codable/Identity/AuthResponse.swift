import Foundation

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
