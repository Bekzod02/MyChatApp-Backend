import Chaqmoq
import Foundation

/// Everything the composition root builds by hand, held together in one place so `routes.swift`
/// (and later, other route files) can reach whatever controllers/middleware they need without
/// each one re-wiring its own dependencies.
struct AppServices {
    let userRepository: UserRepository
    let userService: UserService
    let authService: AuthService
    let authController: AuthController
    let authenticationMiddleware: AuthenticationMiddleware
}

/// Builds every Repository/Service/Controller by hand — no DI container for v1 (see the design
/// doc §2.0 for why). This is the one place in the whole app where concrete types get wired
/// together; everywhere else, code receives its dependencies through its initializer and has no
/// idea how they were constructed.
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

/// Reads the JWT signing secret from the `JWT_SECRET` environment variable. Outside
/// `.production` this falls back to a fixed, well-known value — good enough for running the
/// server on your own machine, where nobody else can reach it. In `.production`, the same
/// fallback would mean anyone who has read this source file (which is public, on GitHub) could
/// forge a valid access token for any user — so production refuses to start at all rather than
/// silently running with a secret that isn't actually secret. Failing loudly at startup beats
/// failing invisibly at 3am.
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
