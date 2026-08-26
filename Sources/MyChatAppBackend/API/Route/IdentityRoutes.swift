import Chaqmoq

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
