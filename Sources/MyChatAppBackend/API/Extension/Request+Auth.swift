import Chaqmoq

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
