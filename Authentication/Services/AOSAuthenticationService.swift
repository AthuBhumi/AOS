import Foundation
import LocalAuthentication
import Security
import Networking
import Security
import Logging

public final class AOSAuthenticationService: AuthenticationServiceProtocol {
    private let apiClient: APIClient
    public private(set) var activeSession: UserSession?
    
    private let keychainAccessKey = "com.atharva.os.accessToken"
    private let keychainRefreshKey = "com.atharva.os.refreshToken"
    private let keychainSessionKey = "com.atharva.os.sessionMetadata"
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func login(email: String, password: String, completion: @escaping (Result<UserSession, AuthError>) -> Void) {
        // Build raw login request parameters
        let payload: [String: String] = ["email": email, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(.credentialsRejected))
            return
        }
        
        let endpoint = APIEndpoint.login(body: jsonData)
        apiClient.execute(endpoint) { [weak self] (result: Result<LoginResponseDTO, NetworkError>) in
            switch result {
            case .failure(let error):
                AOSLogger.shared.error("Login endpoint failed: \(error.localizedDescription)")
                completion(.failure(.credentialsRejected))
            case .success(let dto):
                let expiryDate = Date().addingTimeInterval(TimeInterval(dto.expiresIn))
                let session = UserSession(
                    userId: dto.userId,
                    email: dto.email,
                    displayName: dto.displayName,
                    activeStage: dto.activeStage,
                    accessToken: dto.accessToken,
                    refreshToken: dto.refreshToken,
                    tokenExpiryDate: expiryDate
                )
                self?.saveSessionToKeychain(session)
                self?.activeSession = session
                completion(.success(session))
            }
        }
    }
    
    public func signup(email: String, password: String, displayName: String, completion: @escaping (Result<UUID, AuthError>) -> Void) {
        let payload: [String: String] = [
            "email": email,
            "password": password,
            "displayName": displayName
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(.invalidEmail))
            return
        }
        
        let endpoint = APIEndpoint.signup(body: jsonData)
        apiClient.execute(endpoint) { (result: Result<SignupResponseDTO, NetworkError>) in
            switch result {
            case .failure(let error):
                completion(.failure(.networkFailure(error.localizedDescription)))
            case .success(let dto):
                completion(.success(dto.userId))
            }
        }
    }
    
    public func logout(completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard let session = activeSession else {
            completion(.success(()))
            return
        }
        
        let endpoint = APIEndpoint.logout(refreshToken: session.refreshToken)
        apiClient.execute(endpoint) { [weak self] (result: Result<String?, NetworkError>) in
            // Clean local references regardless of backend call outcome
            self?.clearSessionFromKeychain()
            self?.activeSession = nil
            completion(.success(()))
        }
    }
    
    public func authenticateWithBiometrics(reason: String, completion: @escaping (Result<UserSession, AuthError>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, evalError in
                DispatchQueue.main.async {
                    if success {
                        // Retrieve session from Keychain securely
                        if let savedSession = self?.loadSessionFromKeychain() {
                            self?.activeSession = savedSession
                            completion(.success(savedSession))
                        } else {
                            completion(.failure(.credentialsRejected))
                        }
                    } else {
                        completion(.failure(.biometricAuthenticationFailed))
                    }
                }
            }
        } else {
            completion(.failure(.biometricAuthenticationFailed))
        }
    }
    
    public func restoreSession(completion: @escaping (Bool) -> Void) {
        if let session = loadSessionFromKeychain() {
            // Validate token expiry (e.g. requires refresh if near expiry)
            if session.tokenExpiryDate > Date() {
                self.activeSession = session
                completion(true)
            } else {
                // Execute token refresh synchronously or return expired
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    // MARK: - Keychain Session Storage
    private func saveSessionToKeychain(_ session: UserSession) {
        KeychainManager.shared.save(key: keychainAccessKey, secret: session.accessToken)
        KeychainManager.shared.save(key: keychainRefreshKey, secret: session.refreshToken)
        if let metadataJson = try? JSONEncoder().encode(session),
           let metadataString = String(data: metadataJson, encoding: .utf8) {
            KeychainManager.shared.save(key: keychainSessionKey, secret: metadataString)
        }
    }
    
    private func loadSessionFromKeychain() -> UserSession? {
        guard let metadataString = KeychainManager.shared.load(key: keychainSessionKey),
              let data = metadataString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(UserSession.self, from: data)
    }
    
    private func clearSessionFromKeychain() {
        KeychainManager.shared.delete(key: keychainAccessKey)
        KeychainManager.shared.delete(key: keychainRefreshKey)
        KeychainManager.shared.delete(key: keychainSessionKey)
    }
}
