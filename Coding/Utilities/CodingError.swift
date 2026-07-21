import Foundation

public enum CodingError: Error, LocalizedError {
    case nodeNotFound
    case incorrectAnswer
    
    public var errorDescription: String? {
        switch self {
        case .nodeNotFound:
            return "The requested roadmap node could not be loaded from local storage."
        case .incorrectAnswer:
            return "Incorrect answer selected. Please review study notes and try again."
        }
    }
}
