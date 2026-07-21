import SwiftUI

public enum AuthRoute: Hashable {
    case login
    case signup
    case forgotPassword
    case profileSetup
}

@Observable
public final class AuthCoordinator {
    public var path = NavigationPath()
    public var presentedSheet: AuthRoute?
    
    private let authService: AuthenticationServiceProtocol
    private let onAuthSuccess: (UserSession) -> Void
    
    public init(authService: AuthenticationServiceProtocol, onAuthSuccess: @escaping (UserSession) -> Void) {
        self.authService = authService
        self.onAuthSuccess = onAuthSuccess
    }
    
    public func navigate(to route: AuthRoute) {
        if route == .forgotPassword {
            presentedSheet = .forgotPassword
        } else {
            path.append(route)
        }
    }
    
    public func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    public func completeAuthentication(with session: UserSession) {
        onAuthSuccess(session)
    }
}
