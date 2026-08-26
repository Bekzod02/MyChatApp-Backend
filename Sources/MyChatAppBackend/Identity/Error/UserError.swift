import Foundation

public enum UserError: Error, Equatable {
    case usernameTaken(String)
    case emailTaken(String)
    case idNotFound(UUID)
    case invalidUsername(String)
    case invalidEmail(String)
    case invalidPassword
    case invalidCredentials
}
