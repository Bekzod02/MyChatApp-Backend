import Foundation

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
