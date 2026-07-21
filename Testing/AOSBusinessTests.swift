import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Business

final class AOSBusinessTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and LeanCanvas schemas
        try manager.initializeContainer(with: [User.self, LeanCanvas.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Completeness Score & Overdue Revisions Tests
    func testLeanCanvasAnalyticsCalculations() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let businessRepo = AOSBusinessRepository(storageManager: manager)
        let viewModel = BusinessViewModel(businessRepository: businessRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        viewModel.loadCanvas(forUser: userId)
        
        // Assert loaded canvas is empty (completeness = 0.0)
        XCTAssertEqual(viewModel.completenessScore, 0.0)
        XCTAssertFalse(viewModel.isRevisionOverdue)
        
        // Update problem box: completeness = (1 / 9) * 100 = 11.11%, awards +50 XP
        let updateExpectation1 = self.expectation(description: "Problem box is saved")
        viewModel.updateCanvasBox(boxKey: "problem", text: "Developers waste time on manual tracking setup.", forUser: userId) { success in
            XCTAssertTrue(success)
            updateExpectation1.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        XCTAssertEqual(viewModel.completenessScore, 11.1, accuracy: 0.1)
        
        // Update solution box: completeness = (2 / 9) * 100 = 22.22%
        let updateExpectation2 = self.expectation(description: "Solution box is saved")
        viewModel.updateCanvasBox(boxKey: "solution", text: "Create an autonomous operating system.", forUser: userId) { success in
            XCTAssertTrue(success)
            updateExpectation2.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        XCTAssertEqual(viewModel.completenessScore, 22.2, accuracy: 0.1)
        
        // Verify User XP updates (+100 XP added for 2 box updates)
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 200)
        XCTAssertEqual(updatedUser?.charismaStat, 3) // stats incremented
        
        // Set updatedAt 15 days back to trigger overdue revision warning
        let overdueCanvas = try businessRepo.fetchCanvas(forUser: userId)
        overdueCanvas?.updatedAt = Date().addingTimeInterval(-86400 * 15)
        try businessRepo.saveCanvas(overdueCanvas!)
        
        viewModel.loadCanvas(forUser: userId)
        XCTAssertTrue(viewModel.isRevisionOverdue)
    }
}
