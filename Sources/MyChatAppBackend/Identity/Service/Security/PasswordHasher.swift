import BCrypt

struct PasswordHasher {
    private let bcrypt = BCrypt()

    func hash(_ password: String) throws -> String {
        try bcrypt.hash(password)
    }

    func verify(_ password: String, matches hash: String) throws -> Bool {
        try bcrypt.verify(password, against: hash)
    }
}
