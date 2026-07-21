import Foundation
import Observation
import Models
import Repositories

@Observable
public final class ReadingViewModel {
    public var state: ReadingState = .idle
    public var books: [Book] = []
    public var reviewQueue: [Flashcard] = []
    
    private let readingRepository: ReadingRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(readingRepository: ReadingRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.readingRepository = readingRepository
        self.userRepository = userRepository
    }
    
    public func loadBooks() {
        state = .loading
        do {
            var fetchedBooks = try readingRepository.fetchBooks()
            if fetchedBooks.isEmpty {
                let initial = generateDefaultBooks()
                for book in initial {
                    try readingRepository.saveBook(book)
                }
                fetchedBooks = initial
            }
            books = fetchedBooks
            state = .loadedBooks(fetchedBooks)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func addNewBook(title: String, author: String, pages: Int) {
        let book = Book(title: title, author: author, totalPages: pages)
        do {
            try readingRepository.saveBook(book)
            loadBooks()
        } catch {
            state = .failure("Failed to add book: \(error.localizedDescription)")
        }
    }
    
    public func logPagesRead(forBook bookId: UUID, pagesRead: Int, forUser userId: UUID) {
        do {
            let fetched = try readingRepository.fetchBooks()
            guard let book = fetched.first(where: { $0.id == bookId }) else { return }
            
            let previousPages = book.completedPages
            book.completedPages = min(book.totalPages, book.completedPages + pagesRead)
            try readingRepository.saveBook(book)
            
            // If user read a new page section, award +30 XP and INT
            if book.completedPages > previousPages {
                _ = try userRepository.incrementUserXP(amount: 30, attribute: "INT", onUser: userId)
            }
            
            // Auto generate active recall cards when book is completed
            if book.completedPages == book.totalPages {
                generateFlashcards(forBook: bookId)
            }
            
            loadBooks()
        } catch {
            state = .failure("Page logs write failed: \(error.localizedDescription)")
        }
    }
    
    public func loadReviewQueue() {
        state = .loading
        do {
            let queue = try readingRepository.fetchReviewQueue(forDate: Date())
            self.reviewQueue = queue
            state = .loadedReviewQueue(queue)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    // MARK: - SuperMemo-2 (SM-2) Spaced Repetition Algorithm
    public func submitReviewScore(cardId: UUID, score: Int, forUser userId: UUID) {
        do {
            let cards = try readingRepository.fetchReviewQueue(forDate: Date().addingTimeInterval(86400 * 30))
            guard let card = cards.first(where: { $0.id == cardId }) else { return }
            
            let q = Double(score)
            
            // Adjust repetitions and intervals
            if q < 3.0 {
                card.repetitions = 0
                card.interval = 1
            } else {
                if card.repetitions == 0 {
                    card.interval = 1
                } else if card.repetitions == 1 {
                    card.interval = 6
                } else {
                    card.interval = Int(ceil(Double(card.interval) * card.easeFactor))
                }
                card.repetitions += 1
            }
            
            // Calculate ease factor adjustment
            let newEF = card.easeFactor + (0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02))
            card.easeFactor = max(1.3, newEF)
            
            // Schedule next review date
            card.nextReviewDate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(Double(card.interval) * 86400)
            
            try readingRepository.saveFlashcard(card)
            
            // Award +10 XP for recall sessions completed
            _ = try userRepository.incrementUserXP(amount: 10, attribute: "INT", onUser: userId)
            
            loadReviewQueue()
        } catch {
            state = .failure("Flashcard update failed: \(error.localizedDescription)")
        }
    }
    
    private func generateFlashcards(forBook bookId: UUID) {
        let cards = [
            Flashcard(bookId: bookId, question: "What is the core cue-craving loop mechanism?", answer: "Cue triggers cravings, driving responses and creating rewards."),
            Flashcard(bookId: bookId, question: "What is encapsulation in Object-Oriented design?", answer: "Hiding variables under private controls, exposing them via public methods.")
        ]
        try? readingRepository.bulkCreateCards(cards)
    }
    
    private func generateDefaultBooks() -> [Book] {
        return [
            Book(title: "Atomic Habits", author: "James Clear", totalPages: 320, completedPages: 100),
            Book(title: "Clean Code", author: "Robert Martin", totalPages: 460, completedPages: 0)
        ]
    }
}
