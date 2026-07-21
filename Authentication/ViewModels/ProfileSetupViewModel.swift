import Foundation
import Observation

@Observable
public final class ProfileSetupViewModel {
    public var displayName = ""
    public var isLoading = false
    public var errorMessage: String?
    
    private let authService: AuthenticationServiceProtocol
    private let coordinator: AuthCoordinator
    
    public init(authService: AuthenticationServiceProtocol, coordinator: AuthCoordinator) {
        self.authService = authService
        self.coordinator = coordinator
    }
    
    public func saveProfile() {
        errorMessage = nil
        
        guard AuthValidator.isValidDisplayName(displayName) else {
            errorMessage = AuthError.invalidDisplayName.errorDescription
            return
        }
        
        isLoading = true
        // Mock profile update API or updates local session displayName
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            if var session = self?.authService.activeSession {
                session.displayName = self?.displayName
                self?.coordinator.completeAuthentication(with: session)
            } else {
                // Creates temporary session for onboarding flow
                let tempSession = UserSession(
                    userId: UUID(),
                    email: "user@domain.com",
                    displayName: self?.displayName,
                    activeStage: 1,
                    accessToken: "mock_access_token",
                    refreshToken: "mock_refresh_token",
                    tokenExpiryDate: Date().addingTimeInterval(3600)
                )
                self?.coordinator.completeAuthentication(with: tempSession)
            }
        }
    }
}
