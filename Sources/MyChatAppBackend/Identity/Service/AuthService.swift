import Foundation

/// Orchestrates the two auth use cases: signup and login. `UserService` owns "how a User is
/// found/created/persisted"; `AuthService` owns "what it means to prove you are that User" —
/// validating a raw password, hashing it, verifying it, and issuing tokens. Splitting them is
/// Interface Segregation applied to services: code that only ever needs to look up a user by id
/// (say, the Messaging context resolving a `senderId` to show a display name) depends on
/// `UserService`, not on something that also knows about passwords and tokens.
///
/// `PasswordHasher` and `TokenIssuer` are built *inside* this initializer rather than being
/// constructed by the composition root and injected in. That's a deliberate choice, not an
/// oversight: both currently have exactly one real implementation, so there's nothing to inject —
/// injecting them would only mean the composition root needs to know their types, which would
/// force them to be `public` even though nothing outside `Identity/` should ever construct one
/// directly. `AuthService`'s public surface takes a plain `String` secret instead, which keeps
/// `PasswordHasher`/`TokenIssuer` as private implementation details of Identity, not part of its
/// public API. If either one ever grows a second real implementation worth swapping (unlikely for
/// BCrypt; plausible for token issuance if MyChatApp later needs multiple signing keys for
/// rotation), *that's* the concrete trigger to promote it to a protocol and inject it — not
/// before (see the design doc §2.4/§3.5 for the same "protocol only when there's a real second
/// implementation" rule applied elsewhere).
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
        // Deliberately the same error for "no such email" and "wrong password": if these were
        // distinguishable, an attacker could probe arbitrary emails and learn which ones have
        // accounts (user enumeration) just from the error message, without ever guessing a
        // password.
        guard let user = await userService.findOne(byEmail: email),
              try passwordHasher.verify(password, matches: user.passwordHash)
        else {
            throw UserError.invalidCredentials
        }

        return issueResult(for: user)
    }

    /// Verifies a bearer token from an incoming request and resolves it back to a `User`. This is
    /// what `AuthenticationMiddleware` (design doc §2.5) will call once the API layer exists.
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
