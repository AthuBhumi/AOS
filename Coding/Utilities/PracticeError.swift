import Foundation

public enum PracticeError: Error, LocalizedError {
    case problemNotFound
    case compileTimeout
    
    public var errorDescription: String? {
        switch self {
        case .problemNotFound:
            return "The requested coding problem challenge could not be loaded from local storage."
        case .compileTimeout:
            return "The compiler execution timed out. Please review algorithms loops constraints."
        }
    }
}
