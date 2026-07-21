import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSBusinessBuilderRepository: BusinessBuilderRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSBusinessBuilderRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchIdeas(forUser userId: UUID) throws -> [StartupIdea] {
        let desc = FetchDescriptor<StartupIdea>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        return try context.fetch(desc)
    }
    
    public func saveIdea(_ idea: StartupIdea) throws {
        context.insert(idea)
        idea.incrementClock()
        idea.syncState = 2
        try storageManager.save()
    }
}
