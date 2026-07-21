import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSReadingRepository: ReadingRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSReadingRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchBooks() throws -> [Book] {
        let descriptor = FetchDescriptor<Book>(
            predicate: #Predicate { !$0.isDeleted }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch Books: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveBook(_ book: Book) throws {
        context.insert(book)
        book.incrementClock()
        book.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func fetchFlashcards(forBook bookId: UUID) throws -> [Flashcard] {
        let descriptor = FetchDescriptor<Flashcard>(
            predicate: #Predicate { $0.bookId == bookId && !$0.isDeleted }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch Flashcards: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func fetchReviewQueue(forDate date: Date) throws -> [Flashcard] {
        let calendar = Calendar.current
        let startOfNextDay = calendar.startOfDay(for: date).addingTimeInterval(86400)
        
        let descriptor = FetchDescriptor<Flashcard>(
            predicate: #Predicate { $0.nextReviewDate < startOfNextDay && !$0.isDeleted }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch review queue: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveFlashcard(_ card: Flashcard) throws {
        context.insert(card)
        card.incrementClock()
        card.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func bulkCreateCards(_ cards: [Flashcard]) throws {
        for card in cards {
            context.insert(card)
            card.syncState = 1 // Pending Create
        }
        try storageManager.save()
    }
}
