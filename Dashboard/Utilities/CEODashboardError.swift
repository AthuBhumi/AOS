import Foundation

public enum CEODashboardError: Error, LocalizedError {
    case decisionNotFound
    
    public var errorDescription: String? {
        switch self {
        case .decisionNotFound:
            return "The requested executive decision could not be located in local databases."
        }
    }
}
