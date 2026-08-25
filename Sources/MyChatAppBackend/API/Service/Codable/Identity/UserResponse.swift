import Foundation

/// What `GET /v1/me` returns. Deliberately hand-picks which `User` fields go over the wire —
/// notice `passwordHash` isn't one of them. This is the concrete payoff of never making `User`
/// itself `Encodable`: there's no `Codable` conformance on the entity that a future edit could
/// carelessly extend and accidentally leak a password hash into an API response. The translation
/// has to be written by hand, every time, which is the point.
struct UserResponse: Encodable {
    let id: UUID
    let username: String
    let email: String
    let createdAt: Date

    init(_ user: User) {
        id = user.id
        username = user.username
        email = user.email
        createdAt = user.createdAt
    }
}
