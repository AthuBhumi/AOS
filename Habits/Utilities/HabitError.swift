import Foundation

public enum HabitError: Error, LocalizedError {
    case habitNotFound
    case duplicateCompletion
    
    public var errorDescription: String? {
        switch self {
        case .habitNotFound:
            return "The requested habit log could not be located in local databases."
        case .duplicateCompletion:
            return "Habit has already been completed today."
        }
    }
}
