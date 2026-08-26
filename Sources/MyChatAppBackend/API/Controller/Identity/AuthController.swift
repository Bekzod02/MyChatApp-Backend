import Chaqmoq

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

    func me(request: Request) async throws -> Response {
        guard let user = request.currentUser else {
            return try Response.json(ErrorResponse(code: "unauthorized", message: "Not authenticated."), status: .unauthorized)
        }
        return try Response.json(UserResponse(user))
    }
}
