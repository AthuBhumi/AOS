import Foundation

public enum AdvancedFinanceError: Error, LocalizedError {
    case invalidInput
    case storageError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Please provide valid numeric inputs."
        case .storageError(let desc):
            return "Local database save failed: \(desc)"
        }
    }
}
