import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Coding

final class AOSRoadmapTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and RoadmapNode schemas
        try manager.initializeContainer(with: [User.self, RoadmapNode.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Core Roadmap Unlocking Logic Tests
    func testRoadmapNodeUnlockingFlow() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let roadmapRepo = AOSRoadmapRepository(storageManager: manager)
        let viewModel = RoadmapViewModel(roadmapRepository: roadmapRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        // Loads roadmap nodes triggers automatic bulk creations
        viewModel.loadRoadmap()
        
        guard case .loaded(let nodes) = viewModel.state else {
            XCTFail("State not loaded")
            return
        }
        
        XCTAssertEqual(nodes.count, 3)
        
        // Target Node 1 (Java Syntax & Types): unlocked by default, incomplete
        let node1 = nodes[0]
        XCTAssertFalse(node1.isLocked)
        XCTAssertFalse(node1.isCompleted)
        
        // Target Node 2 (OOP Paradigms): locked
        let node2 = nodes[1]
        XCTAssertTrue(node2.isLocked)
        
        // Submit incorrect answer: fails, returns failure
        let quizExpectation = self.expectation(description: "Incorrect answer fails")
        viewModel.submitQuizAnswer(nodeId: node1.id, selectedIndex: 0, forUser: userId) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error, .incorrectAnswer)
            } else {
                XCTFail("Should return incorrect answer exception")
            }
            quizExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // Submit correct answer: succeeds, completes node1, unlocks node2, awards +100 XP
        let quizSuccessExpectation = self.expectation(description: "Correct answer succeeds")
        viewModel.submitQuizAnswer(nodeId: node1.id, selectedIndex: node1.correctOptionIndex, forUser: userId) { result in
            if case .success(let ok) = result {
                XCTAssertTrue(ok)
            } else {
                XCTFail("Should return success")
            }
            quizSuccessExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // Reload nodes state
        guard case .loaded(let updatedNodes) = viewModel.state else {
            XCTFail("State reload failed")
            return
        }
        
        XCTAssertTrue(updatedNodes[0].isCompleted)
        // OOP Paradigms node should now be unlocked!
        XCTAssertFalse(updatedNodes[1].isLocked)
        
        // Verify User stats updates: totalXP increases to 200 (100 base + 100 reward)
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 200)
        XCTAssertEqual(updatedUser?.intelligenceStat, 2) // Stats incremented
        
        // Progress percentage check: 1 completed out of 3 total = 33.33%
        XCTAssertEqual(viewModel.completionPercentage, 33.33333333333333, accuracy: 0.1)
    }
}
