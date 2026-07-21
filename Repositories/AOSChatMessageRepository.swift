import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSChatMessageRepository: ChatMessageRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSChatMessageRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchMessages(forUser userId: UUID, advisor: String, limit: Int) throws -> [ChatMessage] {
        let descriptor = FetchDescriptor<ChatMessage>(
            predicate: #Predicate { $0.userId == userId && $0.advisor == advisor && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        do {
            let allMessages = try context.fetch(descriptor)
            // Perform sliding window slice locally
            if allMessages.count > limit {
                return Array(allMessages.suffix(limit))
            }
            return allMessages
        } catch {
            AOSLogger.shared.error("Failed to fetch ChatMessages: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveMessage(_ message: ChatMessage) throws {
        context.insert(message)
        message.incrementClock()
        message.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func clearHistory(forUser userId: UUID, advisor: String) throws {
        let descriptor = FetchDescriptor<ChatMessage>(
            predicate: #Predicate { $0.userId == userId && $0.advisor == advisor && !$0.isDeleted }
        )
        do {
            let messages = try context.fetch(descriptor)
            for message in messages {
                message.isDeleted = true
                message.syncState = 3 // Pending Delete
                message.incrementClock()
            }
            try storageManager.save()
        } catch {
            AOSLogger.shared.error("Failed to clear chat history: \(error.localizedDescription)")
            throw StorageError.deleteFailed(error)
        }
    }
}
