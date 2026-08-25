import Chaqmoq

@main
struct MyChatAppBackend {
    static func main() throws {
        let app = Chaqmoq()
        let services = buildServices(environment: app.environment)
        registerRoutes(for: app, services: services)

        app.get { _ in "MyChatAppBackend is running.\n" }

        try app.run()
    }
}
