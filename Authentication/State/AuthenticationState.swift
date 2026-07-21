import Foundation

public enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(UserSession)
    case sessionExpired
}
