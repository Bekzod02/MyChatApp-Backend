import Foundation

/// The Identity context's aggregate root: a person who can authenticate and exchange messages.
///
/// Validation constants live as `static let` right here on the entity (not in a separate
/// validator file), so anyone reading `User.swift` sees the whole contract — what makes a
/// username, email, or password valid — in one place.
///
/// Every stored property is `private(set)` (or `let`): code outside `Identity/` can read a
/// `User`, but can never mutate it into an invalid state directly. The only way to create or
/// change a `User` is through `UserFactory` and `UserService`, which enforce invariants before
/// calling in here. Today that's a discipline, enforced by convention — once `Identity/` is
/// promoted from a folder to its own SPM target (see the design doc §8), `init` staying
/// non-`public` turns this into something the compiler enforces for real.
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
