import Chaqmoq

/// Guards a route group behind a valid access token. Reads the bearer token off the request,
/// asks `AuthService` to verify it and resolve the `User` it belongs to, and either lets the
/// request through (with `currentUser` now set) or short-circuits with `401 Unauthorized`.
///
/// A plain `struct` conforming to `Middleware` — no class, no shared mutable state — matching
/// the same "constructor injection, nothing ambient" approach used everywhere else in `API/`.
struct AuthenticationMiddleware: Middleware {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func handle(request: Request, responder: @escaping Responder) async throws -> any Encodable & Sendable {
        guard let token = request.bearerToken else {
            return try Response.json(ErrorResponse(code: "unauthorized", message: "Missing bearer token."), status: .unauthorized)
        }

        var request = request
        do {
            request.setCurrentUser(try await authService.authenticate(token: token))
        } catch {
            return try Response.json(ErrorResponse(code: "unauthorized", message: "Invalid or expired token."), status: .unauthorized)
        }

        return try await responder(request)
    }
}
