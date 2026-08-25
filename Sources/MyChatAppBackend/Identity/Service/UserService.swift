import Foundation

/// Business logic for the `User` entity: uniqueness checks, delegating construction to
/// `UserFactory`, and persistence via `UserRepository`. Constructor-injected with only the one
/// dependency it actually uses — no ambient container, nothing unused.
public final class UserService: Sendable {
    private let repository: UserRepository
    private let factory = UserFactory()

    public init(repository: UserRepository) {
        self.repository = repository
    }
}

// MARK: - Commands

extension UserService {
    public func register(username: String, email: String, passwordHash: String) async throws -> User {
        if await repository.fetchOne(byUsername: username) != nil {
            throw UserError.usernameTaken(username)
        }
        if await repository.fetchOne(byEmail: email) != nil {
            throw UserError.emailTaken(email)
        }

        let user = try factory.create(username: username, email: email, passwordHash: passwordHash)
        await repository.save(user)
        return user
    }
}

// MARK: - Queries

extension UserService {
    public func findOne(byID id: UUID) async throws -> User {
        guard let user = await repository.fetchOne(byID: id) else { throw UserError.idNotFound(id) }
        return user
    }

    public func findOne(byEmail email: String) async -> User? {
        await repository.fetchOne(byEmail: email)
    }
}
