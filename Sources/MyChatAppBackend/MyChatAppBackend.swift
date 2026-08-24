import Chaqmoq

@main
struct MyChatAppBackend {
    static func main() throws {
        let app = Chaqmoq()
        app.get { _ in "Hello, World! \n" }
        try app.run()
    }
}
