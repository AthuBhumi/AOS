import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSJournalRepository: JournalRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSJournalRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchEntries() throws -> [JournalEntry] {
        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch JournalEntries: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveEntry(_ entry: JournalEntry) throws {
        context.insert(entry)
        entry.incrementClock()
        entry.syncState = 2 // Pending Update
        try storageManager.save()
    }
}
