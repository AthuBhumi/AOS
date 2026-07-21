import Foundation

public enum ReadingError: Error, LocalizedError {
    case bookNotFound
    case cardNotFound
    
    public var errorDescription: String? {
        switch self {
        case .bookNotFound:
            return "The requested book could not be located in local databases."
        case .cardNotFound:
            return "Active recall flashcard item not found."
        }
    }
}
