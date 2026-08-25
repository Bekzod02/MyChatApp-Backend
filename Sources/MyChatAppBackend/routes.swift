import Chaqmoq

/// Where every module's route function gets called and composed into the full route tree. For
/// v1 that's just `/v1/auth/*` and `/v1/me` — as Messaging routes are added, they get called
/// here too, nested under whatever middleware group they need (public, authenticated, ...).
func registerRoutes(for app: Chaqmoq, services: AppServices) {
    app.group("/v1", name: "v1_") { v1 in
        identityRoutes(
            group: v1,
            authController: services.authController,
            authenticationMiddleware: services.authenticationMiddleware
        )
    }
}
