import Foundation

public enum AuthError: Error, LocalizedError {
    case invalidEmail
    case weakPassword
    case invalidDisplayName
    case networkFailure(String)
    case biometricAuthenticationFailed
    case credentialsRejected
    
    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address (e.g., name@domain.com)."
        case .weakPassword:
            return "Password must be at least 8 characters long, containing an uppercase letter, lowercase letter, a digit, and a special character."
        case .invalidDisplayName:
            return "Display name must be between 2 and 32 characters."
        case .networkFailure(let msg):
            return "Authentication request failed: \(msg)"
        case .biometricAuthenticationFailed:
            return "FaceID verification failed or biometric access is disabled."
        case .credentialsRejected:
            return "Incorrect email or password."
        }
    }
}
