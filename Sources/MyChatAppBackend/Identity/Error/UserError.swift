import Foundation

/// Errors raised by the Identity context. One flat enum per entity (not a single catch-all
/// `AppError`) so a call site catching `UserError` knows exactly what shape of failure it's
/// dealing with — Interface Segregation applied to error types, not just protocols.
public enum UserError: Error, Equatable {
    case usernameTaken(String)
    case emailTaken(String)
    case idNotFound(UUID)
    case invalidUsername(String)
    case invalidEmail(String)
    case invalidPassword
    case invalidCredentials
}
