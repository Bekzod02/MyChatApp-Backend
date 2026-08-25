import BCrypt

/// Thin wrapper around chaqmoq's BCrypt implementation — deliberately thin, because password
/// hashing itself should never be hand-rolled. BCrypt (like Argon2 or scrypt) is intentionally
/// slow and salts every hash automatically, which is exactly what a fast general-purpose hash
/// like SHA-256 does *not* give you: an attacker holding a stolen table of SHA-256 password
/// hashes can try billions of guesses a second on commodity hardware, while the same attacker can
/// only try a few thousand BCrypt guesses a second, because BCrypt is designed to be expensive to
/// compute — for the server and the attacker equally.
///
/// Non-public and constructed only inside `AuthService` (see `AuthService.swift`), not injected
/// from the composition root — see that file's doc comment for why.
struct PasswordHasher {
    private let bcrypt = BCrypt()

    func hash(_ password: String) throws -> String {
        try bcrypt.hash(password)
    }

    func verify(_ password: String, matches hash: String) throws -> Bool {
        try bcrypt.verify(password, against: hash)
    }
}
