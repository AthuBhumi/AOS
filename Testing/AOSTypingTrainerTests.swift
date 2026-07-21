import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Coding

final class AOSTypingTrainerTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and TypingSession schemas
        try manager.initializeContainer(with: [User.self, TypingSession.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Core Speed Typing Calculations Tests
    func testWPMAndAccuracyCalculations() {
        let typingRepo = AOSTypingRepository(storageManager: manager)
        let userRepo = AOSUserRepository(storageManager: manager)
        let viewModel = TypingTrainerViewModel(typingRepository: typingRepo, userRepository: userRepo)
        
        viewModel.targetPhrase = "System.out.println(\"Hello World\");"
        viewModel.startSession()
        
        // Mock start date 30 seconds back to compute stable WPM
        viewModel.startTime = Date().addingTimeInterval(-30.0)
        
        // User typed: "System.out.println(" (20 characters)
        // 1 mismatch out of 20 characters
        viewModel.typedPhrase = "System.out.printlO("
        
        // Verify WPM: (20 chars / 5) / 0.5 mins = 8.0 WPM
        XCTAssertEqual(viewModel.currentWPM, 8.0)
        
        // Verify Accuracy: 19 correct out of 20 typed = 95.0%
        XCTAssertEqual(viewModel.currentAccuracy, 95.0)
    }
    
    // MARK: - Typing Stats Database Commit Tests
    func testTypingSessionDatabaseCommit() throws {
        let typingRepo = AOSTypingRepository(storageManager: manager)
        let userRepo = AOSUserRepository(storageManager: manager)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        let viewModel = TypingTrainerViewModel(typingRepository: typingRepo, userRepository: userRepo)
        
        viewModel.targetPhrase = "System"
        viewModel.startSession()
        
        // Complete type matching
        viewModel.updateTypedText("System", userId: userId)
        
        // Assert complete session state matches
        guard case .complete(let session) = viewModel.state else {
            XCTFail("Should transition to complete state")
            return
        }
        
        XCTAssertEqual(session.accuracy, 100.0)
        
        // Fetch sessions
        let stored = try typingRepo.fetchSessions(forUser: userId)
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored.first?.targetPhrase, "System")
    }
}
