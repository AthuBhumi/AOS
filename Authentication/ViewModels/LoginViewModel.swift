import Foundation
import Observation

@Observable
public final class LoginViewModel {
    public var email = ""
    public var password = ""
    public var isLoading = false
    public var errorMessage: String?
    
    private let authService: AuthenticationServiceProtocol
    private let coordinator: AuthCoordinator
    
    public init(authService: AuthenticationServiceProtocol, coordinator: AuthCoordinator) {
        self.authService = authService
        self.coordinator = coordinator
    }
    
    public func login() {
        errorMessage = nil
        
        guard AuthValidator.isValidEmail(email) else {
            errorMessage = AuthError.invalidEmail.errorDescription
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password field cannot be empty."
            return
        }
        
        isLoading = true
        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .success(let session):
                    self?.coordinator.completeAuthentication(with: session)
                }
            }
        }
    }
    
    public func loginWithBiometrics() {
        errorMessage = nil
        isLoading = true
        
        authService.authenticateWithBiometrics(reason: "Login to your ATHARVA OS account securely") { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .success(let session):
                    self?.coordinator.completeAuthentication(with: session)
                }
            }
        }
    }
    
    public func navigateToSignup() {
        coordinator.navigate(to: .signup)
    }
    
    public func navigateToForgotPassword() {
        coordinator.navigate(to: .forgotPassword)
    }
}
