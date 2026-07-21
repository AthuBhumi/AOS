import Foundation
import Models

public protocol ReadingRepositoryProtocol {
    func fetchBooks() throws -> [Book]
    func saveBook(_ book: Book) throws
    func fetchFlashcards(forBook bookId: UUID) throws -> [Flashcard]
    func fetchReviewQueue(forDate date: Date) throws -> [Flashcard]
    func saveFlashcard(_ card: Flashcard) throws
    func bulkCreateCards(_ cards: [Flashcard]) throws
}
