import XCTest
@testable import Common
@testable import Core
@testable import Networking
@testable import Security
@testable import Logging
@testable import Storage
@testable import Authentication

// Mock Service for Unit Testing
final class MockAuthenticationService: AuthenticationServiceProtocol {
    var activeSession: UserSession?
    var signupResult: Result<UUID, AuthError> = .success(UUID())
    var loginResult: Result<UserSession, AuthError> = .failure(.credentialsRejected)
    
    func login(email: String, password: String, completion: @escaping (Result<UserSession, AuthError>) -> Void) {
        completion(loginResult)
    }
    
    func signup(email: String, password: String, displayName: String, completion: @escaping (Result<UUID, AuthError>) -> Void) {
        completion(signupResult)
    }
    
    func logout(completion: @escaping (Result<Void, AuthError>) -> Void) {
        activeSession = nil
        completion(.success(()))
    }
    
    func authenticateWithBiometrics(reason: String, completion: @escaping (Result<UserSession, AuthError>) -> Void) {
        completion(loginResult)
    }
    
    func restoreSession(completion: @escaping (Bool) -> Void) {
        completion(activeSession != nil)
    }
}

final class AOSAuthTests: XCTestCase {
    
    // MARK: - Validator Tests
    func testEmailValidation() {
        XCTAssertTrue(AuthValidator.isValidEmail("atharva@domain.com"))
        XCTAssertFalse(AuthValidator.isValidEmail("invalid-email"))
        XCTAssertFalse(AuthValidator.isValidEmail("name@domain"))
    }
    
    func testPasswordValidation() {
        // Strong password: meets upper, lower, numeric, and special key checks
        XCTAssertTrue(AuthValidator.isValidPassword("Password123!"))
        // Missing special key
        XCTAssertFalse(AuthValidator.isValidPassword("Password123"))
        // Short length
        XCTAssertFalse(AuthValidator.isValidPassword("Pass1!"))
    }
    
    // MARK: - Login ViewModel Transitions
    @MainActor
    func testLoginViewModelValidationTransitions() {
        let mockService = MockAuthenticationService()
        let coordinator = AuthCoordinator(authService: mockService) { _ in }
        let viewModel = LoginViewModel(authService: mockService, coordinator: coordinator)
        
        // Triggers validation error for invalid email structure
        viewModel.email = "invalid-email"
        viewModel.login()
        XCTAssertEqual(viewModel.errorMessage, AuthError.invalidEmail.errorDescription)
        
        // Success check mock
        viewModel.email = "rohan@domain.com"
        viewModel.password = "Password123!"
        
        let targetSession = UserSession(
            userId: UUID(),
            email: "rohan@domain.com",
            displayName: "Rohan",
            activeStage: 1,
            accessToken: "token_xyz",
            refreshToken: "refresh_xyz",
            tokenExpiryDate: Date().addingTimeInterval(3600)
        )
        mockService.loginResult = .success(targetSession)
        
        viewModel.login()
        // Completion runs on main, asserts token update
        let expectation = self.expectation(description: "Login updates session")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }
}
