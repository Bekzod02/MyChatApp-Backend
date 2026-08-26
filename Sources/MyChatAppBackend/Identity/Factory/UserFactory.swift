import Foundation

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
    var isValidEmailShape: Bool {
        let parts = split(separator: "@")
        guard parts.count == 2, parts[1].contains(".") else { return false }
        return true
    }
}
