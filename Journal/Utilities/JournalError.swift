import Foundation

public enum JournalError: Error, LocalizedError {
    case entryNotFound
    
    public var errorDescription: String? {
        switch self {
        case .entryNotFound:
            return "The requested journal entry could not be located in local databases."
        }
    }
}
