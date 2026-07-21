import Foundation

public enum TypingError: Error, LocalizedError {
    case invalidSession
    case storageWriteFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidSession:
            return "Active typing session variables are corrupted or uninitialized."
        case .storageWriteFailed:
            return "Unable to write typing speed stats to local SQLCipher databases."
        }
    }
}
