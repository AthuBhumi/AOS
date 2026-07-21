import Foundation

public enum AIError: Error, LocalizedError {
    case contextLimitExceeded
    case responseStreamFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .contextLimitExceeded:
            return "The active conversation context has exceeded constraints. Resetting thread."
        case .responseStreamFailed(let reason):
            return "Unable to receive streaming responses from LLM endpoints: \(reason)"
        }
    }
}
