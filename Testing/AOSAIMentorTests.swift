import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import AI

final class AOSAIMentorTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with ChatMessage schema
        try manager.initializeContainer(with: [ChatMessage.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Chat Database History Logs Tests
    func testChatLogLifecycle() throws {
        let chatRepo = AOSChatMessageRepository(storageManager: manager)
        let userId = UUID()
        
        let message1 = ChatMessage(userId: userId, advisor: "CTO", role: "user", content: "Implement thread locks in Java")
        let message2 = ChatMessage(userId: userId, advisor: "CTO", role: "assistant", content: "Use ReentrantLock to prevent deadlocks")
        
        // Save
        try chatRepo.saveMessage(message1)
        try chatRepo.saveMessage(message2)
        
        // Fetch: Slide limit caps at 20
        let logs = try chatRepo.fetchMessages(forUser: userId, advisor: "CTO", limit: 20)
        XCTAssertEqual(logs.count, 2)
        XCTAssertEqual(logs.first?.content, "Implement thread locks in Java")
        
        // Clear
        try chatRepo.clearHistory(forUser: userId, advisor: "CTO")
        let postClearLogs = try chatRepo.fetchMessages(forUser: userId, advisor: "CTO", limit: 20)
        XCTAssertTrue(postClearLogs.isEmpty)
    }
    
    // MARK: - Advisor Token Stream Validation Tests
    func testTokenStreamYields() async throws {
        let mockClient = APIClient(baseURL: URL(string: "https://api.domain.com")!)
        let service = AOSAIMentorService(apiClient: mockClient)
        
        let stream = service.streamConsultation(prompt: "Check stats", history: [], advisor: "COACH")
        
        var receivedTokens = ""
        for try await token in stream {
            receivedTokens += token
        }
        
        // Asserts that the stream yields a valid non-empty prompt advice mapping COACH rules
        XCTAssertFalse(receivedTokens.isEmpty)
        XCTAssertTrue(receivedTokens.contains("sleep debt"))
    }
}
