import Foundation

public enum FinanceError: Error, LocalizedError {
    case accountNotFound
    
    public var errorDescription: String? {
        switch self {
        case .accountNotFound:
            return "The requested financial account could not be located in local databases."
        }
    }
}
