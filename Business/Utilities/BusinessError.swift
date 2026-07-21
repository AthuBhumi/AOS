import Foundation

public enum BusinessError: Error, LocalizedError {
    case canvasNotFound
    
    public var errorDescription: String? {
        switch self {
        case .canvasNotFound:
            return "The requested Lean Canvas could not be located in local databases."
        }
    }
}
