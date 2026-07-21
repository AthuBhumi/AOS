import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSCEODecisionRepository: CEODecisionRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSCEODecisionRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchDecisions(forUser userId: UUID) throws -> [CEODecision] {
        let desc = FetchDescriptor<CEODecision>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        return try context.fetch(desc)
    }
    
    public func saveDecision(_ decision: CEODecision) throws {
        context.insert(decision)
        decision.incrementClock()
        decision.syncState = 2
        try storageManager.save()
    }
}
