import Foundation

public enum StorageError: Error, LocalizedError {
    case contextNotInitialized
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case migrationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .contextNotInitialized:
            return "The SwiftData database context is not initialized."
        case .saveFailed(let err):
            return "Failed to save records to the local database file: \(err.localizedDescription)"
        case .fetchFailed(let err):
            return "Failed to execute database fetch query: \(err.localizedDescription)"
        case .deleteFailed(let err):
            return "Failed to delete record: \(err.localizedDescription)"
        case .migrationFailed(let details):
            return "Database schema version migration failed: \(details)"
        }
    }
}
