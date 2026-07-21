import Foundation

public protocol AuthenticationServiceProtocol {
    var activeSession: UserSession? { get }
    
    func login(email: String, password: String, completion: @escaping (Result<UserSession, AuthError>) -> Void)
    func signup(email: String, password: String, displayName: String, completion: @escaping (Result<UUID, AuthError>) -> Void)
    func logout(completion: @escaping (Result<Void, AuthError>) -> Void)
    func authenticateWithBiometrics(reason: String, completion: @escaping (Result<UserSession, AuthError>) -> Void)
    func restoreSession(completion: @escaping (Bool) -> Void)
}
