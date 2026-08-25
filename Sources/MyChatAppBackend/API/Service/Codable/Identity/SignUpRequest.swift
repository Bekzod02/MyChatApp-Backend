/// The wire shape of `POST /v1/auth/signup`'s body. A dedicated request type — not `User`
/// itself — because a signup request is deliberately a *subset* of what a `User` ends up being
/// (no `id`, no `createdAt`, a plaintext `password` that never becomes a stored property anywhere).
struct SignUpRequest: Decodable {
    let username: String
    let email: String
    let password: String
}
