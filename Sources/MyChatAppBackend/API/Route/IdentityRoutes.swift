import Chaqmoq

func identityRoutes(
    group: RouteGroup,
    authController: AuthController,
    authenticationMiddleware: AuthenticationMiddleware
) {
    group.group("/auth", name: "auth_") { auth in
        auth.post("/signup", name: "signup") { request in try await authController.signup(request: request) }
        auth.post("/login", name: "login") { request in try await authController.login(request: request) }
    }

    group.group(middleware: [authenticationMiddleware]) { authenticated in
        authenticated.get("/me", name: "me") { request in try await authController.me(request: request) }
    }
}
