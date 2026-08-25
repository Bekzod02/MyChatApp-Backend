import Foundation

/// Owns *how* to construct a valid `User`. `UserService` calls into `UserFactory` rather than
/// building a `User` by hand — that keeps "what makes a User valid" in one place (this file),
/// separate from "what UserService does with a User once it exists" (uniqueness checks against
/// the repository, persistence, orchestration). Single Responsibility applied at the level of one
/// entity, not a whole service.
struct UserFactory {
    func create(username: String, email: String, passwordHash: String) throws -> User {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard User.usernameRange.contains(trimmedUsername.count) else {
            throw UserError.invalidUsername(username)
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmedEmail.count <= User.emailMaxLength, trimmedEmail.isValidEmailShape else {
            throw UserError.invalidEmail(email)
        }

        return User(username: trimmedUsername, email: trimmedEmail, passwordHash: passwordHash)
    }
}

private extension String {
    /// Deliberately loose: this only rejects obviously malformed input ("no @", "no domain").
    /// Real email *validity* can only be proven by sending an email and having it opened — no
    /// regex proves a mailbox exists. A "perfect" RFC 5322 regex here would be solving a problem
    /// this layer can't actually solve, at the cost of rejecting real addresses it misjudges.
    var isValidEmailShape: Bool {
        let parts = split(separator: "@")
        guard parts.count == 2, parts[1].contains(".") else { return false }
        return true
    }
}
