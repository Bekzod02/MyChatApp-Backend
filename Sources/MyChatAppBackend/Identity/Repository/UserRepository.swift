import Foundation

/// The only way any other code reaches `User` storage. No `UserRepositoryProtocol` — this
/// repository has exactly one real implementation, so a protocol would be pure ceremony (see the
/// design doc §2.4). The dependency-inversion guarantee instead comes from the fact that nothing
/// outside `Identity/` is allowed to touch this file's internals; everyone else goes through
/// `UserService`.
///
/// Backed by an in-memory dictionary for v1 — no database yet (see the design doc §6). None of
/// these methods can currently fail, which is why they're not `throws`: adding `throws`
/// speculatively "for when Postgres arrives" would just be unused ceremony today. When a real
/// database is swapped in, `throws` gets added to these signatures then, and the compiler will
/// point at every call site that needs a `try` added — that's a more honest way to grow this
/// interface than pre-paying for a failure mode that doesn't exist yet.
///
/// An `actor` (rather than a `final class` with manual locking) gives thread-safe access to this
/// in-memory state for free — concurrent requests can safely read/write `User`s without a data
/// race, which matters the moment more than one HTTP request is being handled at once.
///
/// Marked `public` — unlike `UserFactory` or the `Security/` types — because this one actually
/// needs to cross the boundary: the composition root (`services.swift`) constructs exactly *one*
/// `UserRepository` at app launch (so every request shares the same in-memory store) and hands
/// that single instance into `UserService`'s initializer. That's a real cross-module need, not a
/// convenience — `UserService.init(repository:)` being `public` forces its parameter type to be
/// `public` too, which is a Swift rule, not a style choice: a public declaration can never expose
/// a less-visible type in its own signature. `PasswordHasher`/`TokenIssuer` avoid this because
/// they don't need to be *shared instances* — see `AuthService.swift`'s doc comment for that
/// contrast.
public actor UserRepository {
    private var usersByID: [UUID: User] = [:]
    private var idsByEmail: [String: UUID] = [:]
    private var idsByUsername: [String: UUID] = [:]

    public init() {}

    func fetchOne(byID id: UUID) -> User? {
        usersByID[id]
    }

    func fetchOne(byEmail email: String) -> User? {
        idsByEmail[email].flatMap { usersByID[$0] }
    }

    func fetchOne(byUsername username: String) -> User? {
        idsByUsername[username].flatMap { usersByID[$0] }
    }

    func save(_ user: User) {
        usersByID[user.id] = user
        idsByEmail[user.email] = user.id
        idsByUsername[user.username] = user.id
    }
}
