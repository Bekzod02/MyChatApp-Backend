import Foundation

public final class AuthService: Sendable {
    private let userService: UserService
    private let passwordHasher = PasswordHasher()
    private let tokenIssuer: TokenIssuer

    public init(userService: UserService, tokenSecret: String, tokenLifetime: TimeInterval = 30 * 60) {
        self.userService = userService
        self.tokenIssuer = TokenIssuer(secret: tokenSecret, lifetime: tokenLifetime)
    }
}

extension AuthService {
    public func register(username: String, email: String, password: String) async throws -> AuthResult {
        guard User.passwordRange.contains(password.count) else {
            throw UserError.invalidPassword
        }

        let passwordHash = try passwordHasher.hash(password)
        let user = try await userService.register(username: username, email: email, passwordHash: passwordHash)

        return issueResult(for: user)
    }

    public func login(email: String, password: String) async throws -> AuthResult {
        guard let user = await userService.findOne(byEmail: email),
              try passwordHasher.verify(password, matches: user.passwordHash)
        else {
            throw UserError.invalidCredentials
        }

        return issueResult(for: user)
    }

    public func authenticate(token: String) async throws -> User {
        guard let userID = tokenIssuer.verify(token) else {
            throw UserError.invalidCredentials
        }
        return try await userService.findOne(byID: userID)
    }

    private func issueResult(for user: User) -> AuthResult {
        let (token, expiresAt) = tokenIssuer.issue(userID: user.id)
        return AuthResult(userID: user.id, accessToken: token, expiresAt: expiresAt)
    }
}
