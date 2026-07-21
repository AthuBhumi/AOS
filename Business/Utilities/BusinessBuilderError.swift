import Foundation

public enum BusinessBuilderError: Error, LocalizedError {
    case ideaNotFound
    
    public var errorDescription: String? {
        switch self {
        case .ideaNotFound:
            return "The requested startup idea could not be located in local databases."
        }
    }
}
