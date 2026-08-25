import Chaqmoq

/// A function, not a type — route registration is a one-time, imperative act (call these methods
/// on this group, in this order), not something that benefits from being modeled as an object
/// with its own state or lifecycle.
func identityRoutes(
    group: RouteGroup,
    authController: AuthController,
    authenticationMiddleware: AuthenticationMiddleware
) {
    group.group("/auth", name: "auth_") { auth in
        auth.post("/signup", name: "signup", handler: authController.signup)
        auth.post("/login", name: "login", handler: authController.login)
    }

    group.group(middleware: [authenticationMiddleware]) { authenticated in
        authenticated.get("/me", name: "me", handler: authController.me)
    }
}
