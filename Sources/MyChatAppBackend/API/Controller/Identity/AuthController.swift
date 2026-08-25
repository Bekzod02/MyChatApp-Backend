import Chaqmoq

/// Thin by design: decode the request body, call the one `AuthService` method that does the
/// actual work, translate the result (or a thrown `UserError`) into an HTTP response. No
/// business logic lives here — that's `AuthService`'s job (`Identity/Service/AuthService.swift`).
///
/// `@unchecked Sendable`: `AuthController` only ever holds an immutable `let authService`, built
/// once in the composition root and never mutated afterwards, so it's safe to hand its methods
/// to chaqmoq as `@Sendable` route handlers — the compiler just can't see that on its own through
/// a plain class, so this is where a human has to assert it instead of the automatic checker.
final class AuthController: @unchecked Sendable {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func signup(request: Request) async throws -> Response {
        guard let data = try? request.body.decode(SignUpRequest.self) else {
            return try Response.json(ErrorResponse(code: "invalid_body", message: "Couldn't read that request body."), status: .badRequest)
        }

        do {
            let result = try await authService.register(username: data.username, email: data.email, password: data.password)
            return try Response.json(AuthResponse(result), status: .created)
        } catch let error as UserError {
            return try Response.json(error.response, status: error.httpStatus)
        }
    }

    func login(request: Request) async throws -> Response {
        guard let data = try? request.body.decode(LoginRequest.self) else {
            return try Response.json(ErrorResponse(code: "invalid_body", message: "Couldn't read that request body."), status: .badRequest)
        }

        do {
            let result = try await authService.login(email: data.email, password: data.password)
            return try Response.json(AuthResponse(result), status: .ok)
        } catch let error as UserError {
            return try Response.json(error.response, status: error.httpStatus)
        }
    }

    /// `GET /v1/me` — sits behind `AuthenticationMiddleware`, so `request.currentUser` is always
    /// set by the time this runs. Exists as the smallest possible proof that the whole loop
    /// works end-to-end: sign up, log in, use the token to reach something that needed it.
    func me(request: Request) async throws -> Response {
        guard let user = request.currentUser else {
            return try Response.json(ErrorResponse(code: "unauthorized", message: "Not authenticated."), status: .unauthorized)
        }
        return try Response.json(UserResponse(user))
    }
}
