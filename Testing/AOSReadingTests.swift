import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Reading

final class AOSReadingTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User, Book and Flashcard schemas
        try manager.initializeContainer(with: [User.self, Book.self, Flashcard.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Spaced Repetition SM-2 Algorithm Tests
    func testSM2AlgorithmCalculations() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let readingRepo = AOSReadingRepository(storageManager: manager)
        let viewModel = ReadingViewModel(readingRepository: readingRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        let bookId = UUID()
        let testBook = Book(id: bookId, title: "Clean Code", author: "Robert Martin", totalPages: 460)
        try readingRepo.saveBook(testBook)
        
        let cardId = UUID()
        let testCard = Flashcard(
            id: cardId,
            bookId: bookId,
            question: "What is SRP?",
            answer: "Single Responsibility Principle",
            interval: 1,
            easeFactor: 2.5,
            repetitions: 0
        )
        try readingRepo.saveFlashcard(testCard)
        
        // Review 1: User rates it "Forgot" (score = 1)
        // Interval should reset/stay at 1 day, repetitions = 0
        viewModel.submitReviewScore(cardId: cardId, score: 1, forUser: userId)
        
        let queue1 = try readingRepo.fetchReviewQueue(forDate: Date().addingTimeInterval(86400 * 30))
        let cardAfter1 = queue1.first(where: { $0.id == cardId })
        XCTAssertEqual(cardAfter1?.repetitions, 0)
        XCTAssertEqual(cardAfter1?.interval, 1)
        // EF decreases under low score
        XCTAssertLessThan(cardAfter1?.easeFactor ?? 0, 2.5)
        
        // Review 2: User rates it "Perfect" (score = 5)
        // repetitions = 0 -> repetitions = 1 -> interval = 1
        let lastEF = cardAfter1?.easeFactor ?? 2.5
        viewModel.submitReviewScore(cardId: cardId, score: 5, forUser: userId)
        
        let queue2 = try readingRepo.fetchReviewQueue(forDate: Date().addingTimeInterval(86400 * 30))
        let cardAfter2 = queue2.first(where: { $0.id == cardId })
        XCTAssertEqual(cardAfter2?.repetitions, 1)
        XCTAssertEqual(cardAfter2?.interval, 1)
        // EF increases under perfect score
        XCTAssertGreaterThan(cardAfter2?.easeFactor ?? 0, lastEF)
        
        // Review 3: User rates it "Perfect" (score = 5) again
        // repetitions = 1 -> repetitions = 2 -> interval = 6
        viewModel.submitReviewScore(cardId: cardId, score: 5, forUser: userId)
        
        let queue3 = try readingRepo.fetchReviewQueue(forDate: Date().addingTimeInterval(86400 * 30))
        let cardAfter3 = queue3.first(where: { $0.id == cardId })
        XCTAssertEqual(cardAfter3?.repetitions, 2)
        XCTAssertEqual(cardAfter3?.interval, 6)
        
        // Review 4: User rates it "Perfect" (score = 5) again
        // repetitions = 2 -> repetitions = 3 -> interval = 6 * EF = 6 * 2.65 = 16 days
        viewModel.submitReviewScore(cardId: cardId, score: 5, forUser: userId)
        
        let queue4 = try readingRepo.fetchReviewQueue(forDate: Date().addingTimeInterval(86400 * 30))
        let cardAfter4 = queue4.first(where: { $0.id == cardId })
        XCTAssertEqual(cardAfter4?.repetitions, 3)
        XCTAssertGreaterThanOrEqual(cardAfter4?.interval ?? 0, 15)
        
        // Verify User XP was added (4 reviews * 10 XP = 40 XP added)
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 140)
    }
}
