import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSTypingRepository: TypingRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSTypingRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchSessions(forUser userId: UUID) throws -> [TypingSession] {
        let descriptor = FetchDescriptor<TypingSession>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch TypingSessions: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveSession(_ session: TypingSession) throws {
        context.insert(session)
        session.incrementClock()
        session.syncState = 2 // Pending Update
        try storageManager.save()
    }
}
