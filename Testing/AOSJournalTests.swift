import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Journal

final class AOSJournalTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and JournalEntry schemas
        try manager.initializeContainer(with: [User.self, JournalEntry.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Cognitive Distortion Checks Tests
    func testCognitiveDistortionFlags() {
        let journalRepo = AOSJournalRepository(storageManager: manager)
        let userRepo = AOSUserRepository(storageManager: manager)
        let viewModel = JournalViewModel(journalRepository: journalRepo, userRepository: userRepo)
        
        // Catastrophizing check
        let text1 = "This compiler error is the worst thing ever, I will definitely fail this class."
        XCTAssertEqual(viewModel.detectCognitiveDistortion(text1), "Catastrophizing")
        
        // All-or-nothing check
        let text2 = "I always break my diet, I have zero self discipline."
        XCTAssertEqual(viewModel.detectCognitiveDistortion(text2), "All-or-Nothing")
        
        // Filtering check
        let text3 = "Rohan ignored my message, I only have bad relationships."
        XCTAssertEqual(viewModel.detectCognitiveDistortion(text3), "Filtering")
        
        // No distortion check
        let text4 = "I had some compile bugs but resolved them."
        XCTAssertNil(viewModel.detectCognitiveDistortion(text4))
    }
    
    // MARK: - CBT Reframing Database Flow Tests
    func testJournalReframingFlow() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let journalRepo = AOSJournalRepository(storageManager: manager)
        let viewModel = JournalViewModel(journalRepository: journalRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        // Input text containing "worst" (Catastrophizing)
        viewModel.contentBuffer = "This syntax bug is the worst, I can never succeed."
        viewModel.moodScore = 3.0
        
        let saveExpectation = self.expectation(description: "Flagged entry triggers reframing state")
        viewModel.commitEntry(title: "Log 1", forUser: userId) { entry in
            XCTAssertEqual(entry.detectedDistortion, "Catastrophizing")
            saveExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // Verify state is reframing
        guard case .reframing(let entry) = viewModel.state else {
            XCTFail("Should enter reframing state")
            return
        }
        
        // Submit Reframing
        viewModel.submitReframing(entry: entry, reframeText: "It is just a minor syntax bug that I can resolve with practice.", forUser: userId)
        
        // Verify state reloads
        XCTAssertEqual(viewModel.state, .loaded(viewModel.entries))
        
        // Verify stored entry contains reframed rationale
        let stored = try journalRepo.fetchEntries()
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored.first?.reframedRationale, "It is just a minor syntax bug that I can resolve with practice.")
        
        // Verify User XP updates (+40 XP awarded for reframing)
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 140)
    }
}
