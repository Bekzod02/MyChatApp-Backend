import Crypto
import Foundation

/// Issues and verifies MyChatApp's access tokens: a minimal, hand-rolled JWT (JSON Web Token).
///
/// A JWT is three base64url-encoded parts joined by dots: `header.payload.signature`. The
/// signature is an HMAC-SHA256 over `header + "." + payload`, computed with a secret only the
/// server knows. Anyone can *read* the payload (it's only base64-encoded, not encrypted) — the
/// signature is what makes it trustworthy: the server can verify a token wasn't tampered with
/// without looking anything up in a database, because recomputing the signature and comparing it
/// is all that's needed. That's what "stateless" means in practice (see the design doc §7 for the
/// lifetime/refresh tradeoffs this implies).
///
/// Hand-rolling this instead of pulling in a JWT library is a deliberate choice for a learning
/// project: the format is small enough to fully own end-to-end, which is worth doing once before
/// ever treating a JWT as a black box.
///
/// Non-public and constructed only inside `AuthService`, not injected from the composition root
/// — see `AuthService.swift`'s doc comment for why.
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

    /// Returns the token's subject (user id) if the signature is valid and it hasn't expired,
    /// `nil` otherwise. Deliberately returns an optional rather than throwing: an expired or
    /// forged token isn't an exceptional programmer error, it's an expected outcome (a session
    /// ran out, or someone's poking at the API) that callers handle as "not authenticated," not
    /// as a crash-worthy failure.
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

    /// A plain `==` on the two signature strings would let an attacker measure how many leading
    /// bytes matched by timing how long the comparison took (it returns as soon as it finds a
    /// mismatch) — a real, historically-exploited class of attack against signature verification.
    /// XOR-ing every byte and only checking the accumulated result at the end takes the same
    /// amount of time no matter where — or whether — a mismatch occurs.
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
