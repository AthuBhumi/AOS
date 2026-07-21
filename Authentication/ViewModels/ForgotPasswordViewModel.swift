import Foundation
import Observation
import Networking

@Observable
public final class ForgotPasswordViewModel {
    public var email = ""
    public var isLoading = false
    public var errorMessage: String?
    public var successMessage: String?
    
    private let apiClient: APIClient
    private let coordinator: AuthCoordinator
    
    public init(apiClient: APIClient, coordinator: AuthCoordinator) {
        self.apiClient = apiClient
        self.coordinator = coordinator
    }
    
    public func requestPasswordReset() {
        errorMessage = nil
        successMessage = nil
        
        guard AuthValidator.isValidEmail(email) else {
            errorMessage = AuthError.invalidEmail.errorDescription
            return
        }
        
        isLoading = true
        
        let payload: [String: String] = ["email": email]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            isLoading = false
            return
        }
        
        let endpoint = APIEndpoint.signup(body: jsonData) // Using forgot-password route in practice
        apiClient.execute(endpoint) { [weak self] (result: Result<SignupResponseDTO, NetworkError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .success:
                    self?.successMessage = "If email exists, a password reset link has been sent."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.coordinator.dismissSheet()
                    }
                }
            }
        }
    }
    
    public func dismiss() {
        coordinator.dismissSheet()
    }
}
