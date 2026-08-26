import Chaqmoq

extension UserError {
    var httpStatus: Response.Status {
        switch self {
        case .usernameTaken, .emailTaken: .conflict
        case .idNotFound: .notFound
        case .invalidUsername, .invalidEmail, .invalidPassword: .badRequest
        case .invalidCredentials: .unauthorized
        }
    }

    var response: ErrorResponse {
        switch self {
        case .usernameTaken: .init(code: "username_taken", message: "That username is already in use.")
        case .emailTaken: .init(code: "email_taken", message: "That email is already in use.")
        case .idNotFound: .init(code: "not_found", message: "User not found.")
        case .invalidUsername: .init(code: "invalid_username", message: "Username must be 3-30 characters.")
        case .invalidEmail: .init(code: "invalid_email", message: "Enter a valid email address.")
        case .invalidPassword: .init(code: "invalid_password", message: "Password must be 8-72 characters.")
        case .invalidCredentials: .init(code: "invalid_credentials", message: "Incorrect email or password.")
        }
    }
}
