import Foundation

public enum ProfileError: Error, LocalizedError {
    case userNotFound
    case updateFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Unable to load the requested user profile metadata from local storage."
        case .updateFailed(let reason):
            return "Failed to update profile settings: \(reason)"
        }
    }
}
