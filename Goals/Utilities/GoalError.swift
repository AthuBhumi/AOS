import Foundation

public enum GoalError: Error, LocalizedError {
    case goalNotFound
    case invalidKeyResult
    
    public var errorDescription: String? {
        switch self {
        case .goalNotFound:
            return "The requested goal could not be located in local databases."
        case .invalidKeyResult:
            return "The target Key Result is uninitialized or missing."
        }
    }
}
