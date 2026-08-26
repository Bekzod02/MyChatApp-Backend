import Foundation

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
