import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import AI
@testable import Finance
@testable import Business
@testable import Reading
@testable import Typing

final class AOSIntegrationTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize default storage manager container in-memory registering all 13 models
        try manager.setupDefaultContainer(isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Core SwiftData Schemas Registry Validation
    func testAllModelsRegistration() {
        XCTAssertNotNil(container, "All 13 model schemas should successfully initialize.")
    }
    
    // MARK: - AI Mentor Context Injection Checks
    func testAIMentorContextGeneration() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let typingRepo = AOSTypingRepository(storageManager: manager)
        let readingRepo = AOSReadingRepository(storageManager: manager)
        let financeRepo = AOSFinanceRepository(storageManager: manager)
        let businessRepo = AOSBusinessBuilderRepository(storageManager: manager)
        
        let mockService = MockAIMentorService()
        let mockChatRepo = MockChatMessageRepository()
        
        let viewModel = AIMentorViewModel(
            aiService: mockService,
            chatRepository: mockChatRepo,
            userRepository: userRepo,
            typingRepository: typingRepo,
            readingRepository: readingRepo,
            financeRepository: financeRepo,
            businessRepository: businessRepo
        )
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 300)
        testUser.level = 3
        try userRepo.saveUser(testUser)
        
        // Add typing drill
        let typingSession = TypingSession(userId: userId, targetPhrase: "java", typedPhrase: "java", wpm: 55.0, accuracy: 100.0, timeSpentSeconds: 5.0)
        try typingRepo.saveSession(typingSession)
        
        // Add book
        let book = Book(title: "Atomic Habits", author: "Clear", totalPages: 100, completedPages: 40)
        try readingRepo.saveBook(book)
        
        // Add cash balance
        let cashAcc = FinancialAccount(userId: userId, name: "Reserve", balance: 5000.0, type: "Cash")
        try financeRepo.saveAccount(cashAcc)
        
        // Add startup canvas
        let canvas = StartupIdea(userId: userId, title: "AOS", problem: "Bugs")
        try businessRepo.saveIdea(canvas)
        
        // Trigger select and send
        viewModel.sendPrompt("Hey advisor, what should I do next?", userId: userId)
        
        // Verify mock prompt contains compiled context header details
        guard let sentPrompt = mockService.receivedPrompt else {
            XCTFail("Prompt not routed")
            return
        }
        
        XCTAssertTrue(sentPrompt.contains("Level: 3"))
        XCTAssertTrue(sentPrompt.contains("Typing Speed: 55.0 WPM"))
        XCTAssertTrue(sentPrompt.contains("Reading Progress: 40/100 pages"))
        XCTAssertTrue(sentPrompt.contains("Lean Canvas Completeness: 11.1%"))
    }
}

// MARK: - Mocks for test context
class MockAIMentorService: AIMentorServiceProtocol {
    var receivedPrompt: String?
    
    func streamConsultation(prompt: String, history: [ChatMessage], advisor: String) -> AsyncThrowingStream<String, Error> {
        self.receivedPrompt = prompt
        return AsyncThrowingStream { continuation in
            continuation.yield("Context verified successfully.")
            continuation.finish()
        }
    }
}

class MockChatMessageRepository: ChatMessageRepositoryProtocol {
    var saved: [ChatMessage] = []
    
    func fetchMessages(forUser userId: UUID, advisor: String, limit: Int) throws -> [ChatMessage] {
        return saved
    }
    
    func saveMessage(_ message: ChatMessage) throws {
        saved.append(message)
    }
    
    func clearHistory(forUser userId: UUID, advisor: String) throws {
        saved.removeAll()
    }
}
