import Foundation
import Observation

@Observable
public final class SignupViewModel {
    public var email = ""
    public var password = ""
    public var displayName = ""
    public var isLoading = false
    public var errorMessage: String?
    public var successMessage: String?
    
    private let authService: AuthenticationServiceProtocol
    private let coordinator: AuthCoordinator
    
    public init(authService: AuthenticationServiceProtocol, coordinator: AuthCoordinator) {
        self.authService = authService
        self.coordinator = coordinator
    }
    
    public func signup() {
        errorMessage = nil
        successMessage = nil
        
        guard AuthValidator.isValidEmail(email) else {
            errorMessage = AuthError.invalidEmail.errorDescription
            return
        }
        
        guard AuthValidator.isValidPassword(password) else {
            errorMessage = AuthError.weakPassword.errorDescription
            return
        }
        
        guard AuthValidator.isValidDisplayName(displayName) else {
            errorMessage = AuthError.invalidDisplayName.errorDescription
            return
        }
        
        isLoading = true
        authService.signup(email: email, password: password, displayName: displayName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .success:
                    self?.successMessage = "Account registered! Proceeding to setup profile."
                    // Route to Profile Setup modal
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self?.coordinator.navigate(to: .profileSetup)
                    }
                }
            }
        }
    }
    
    public func goBackToLogin() {
        coordinator.goBack()
    }
}
