import Crypto
import Foundation

struct TokenIssuer {
    private let secret: SymmetricKey
    private let lifetime: TimeInterval

    init(secret: String, lifetime: TimeInterval) {
        self.secret = SymmetricKey(data: Data(secret.utf8))
        self.lifetime = lifetime
    }

    func issue(userID: UUID, issuedAt: Date = .now) -> (token: String, expiresAt: Date) {
        let expiresAt = issuedAt.addingTimeInterval(lifetime)
        let header = Base64URL.encode(Data(#"{"alg":"HS256","typ":"JWT"}"#.utf8))
        let payloadJSON = """
        {"sub":"\(userID.uuidString)","iat":\(Int(issuedAt.timeIntervalSince1970)),"exp":\(Int(expiresAt.timeIntervalSince1970))}
        """
        let payload = Base64URL.encode(Data(payloadJSON.utf8))
        let signature = sign("\(header).\(payload)")

        return ("\(header).\(payload).\(signature)", expiresAt)
    }

    func verify(_ token: String, now: Date = .now) -> UUID? {
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        let header = String(parts[0]), payload = String(parts[1]), signature = String(parts[2])

        guard constantTimeEquals(sign("\(header).\(payload)"), signature),
              let payloadData = Base64URL.decode(payload),
              let claims = try? JSONDecoder().decode(Claims.self, from: payloadData),
              claims.exp > now.timeIntervalSince1970,
              let userID = UUID(uuidString: claims.sub)
        else { return nil }

        return userID
    }

    private func sign(_ signingInput: String) -> String {
        let code = HMAC<SHA256>.authenticationCode(for: Data(signingInput.utf8), using: secret)
        return Base64URL.encode(Data(code))
    }

    private func constantTimeEquals(_ lhs: String, _ rhs: String) -> Bool {
        let lhsBytes = Array(lhs.utf8), rhsBytes = Array(rhs.utf8)
        guard lhsBytes.count == rhsBytes.count else { return false }

        var mismatch: UInt8 = 0
        for i in 0..<lhsBytes.count { mismatch |= lhsBytes[i] ^ rhsBytes[i] }

        return mismatch == 0
    }
}

private struct Claims: Decodable {
    let sub: String
    let iat: TimeInterval
    let exp: TimeInterval
}

private enum Base64URL {
    static func encode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func decode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        return Data(base64Encoded: base64)
    }
}
