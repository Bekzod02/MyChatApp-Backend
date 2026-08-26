import Foundation

public final class User: Equatable, Sendable {
    public static let usernameRange: ClosedRange<Int> = 3...30
    public static let emailMaxLength = 254
    public static let passwordRange: ClosedRange<Int> = 8...72

    public let id: UUID
    public private(set) var username: String
    public private(set) var email: String
    public private(set) var passwordHash: String
    public let createdAt: Date

    init(
        id: UUID = .init(),
        username: String,
        email: String,
        passwordHash: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.createdAt = createdAt
    }

    public static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }
}
