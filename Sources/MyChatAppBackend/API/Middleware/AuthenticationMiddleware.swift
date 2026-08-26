import Chaqmoq

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
