import Chaqmoq

func registerRoutes(for app: Chaqmoq, services: AppServices) {
    app.group("/v1", name: "v1_") { v1 in
        identityRoutes(
            group: v1,
            authController: services.authController,
            authenticationMiddleware: services.authenticationMiddleware
        )
    }
}
