import Chaqmoq
import Foundation

struct AppServices {
    let userRepository: UserRepository
    let userService: UserService
    let authService: AuthService
    let authController: AuthController
    let authenticationMiddleware: AuthenticationMiddleware
}

func buildServices(environment: Environment) -> AppServices {
    let userRepository = UserRepository()
    let userService = UserService(repository: userRepository)
    let authService = AuthService(userService: userService, tokenSecret: tokenSecret(for: environment))
    let authController = AuthController(authService: authService)
    let authenticationMiddleware = AuthenticationMiddleware(authService: authService)

    return AppServices(
        userRepository: userRepository,
        userService: userService,
        authService: authService,
        authController: authController,
        authenticationMiddleware: authenticationMiddleware
    )
}

private func tokenSecret(for environment: Environment) -> String {
    if let secret = Environment.get("JWT_SECRET") {
        return secret
    }

    guard environment != .production else {
        fatalError("JWT_SECRET must be set in production — refusing to start with no real signing secret.")
    }

    print("⚠️  JWT_SECRET not set — using an insecure development-only default. Never do this in production.")
    return "mychatapp-development-secret-do-not-use-in-production"
}
