import Chaqmoq

/// Bridges chaqmoq's transport-level `Request` to Identity concepts: pulling a bearer token out
/// of the `Authorization` header, and stashing the `User` that `AuthenticationMiddleware` resolves
/// from it so downstream handlers (like `AuthController.me`) can read it back.
extension Request {
    private static let currentUserAttributeKey = "currentUser"

    var bearerToken: String? {
        guard let header = headers.get(.authorization), header.hasPrefix("Bearer ") else { return nil }
        return String(header.dropFirst("Bearer ".count))
    }

    var currentUser: User? {
        getAttribute(Self.currentUserAttributeKey)
    }

    mutating func setCurrentUser(_ user: User) {
        setAttribute(Self.currentUserAttributeKey, value: user)
    }
}
