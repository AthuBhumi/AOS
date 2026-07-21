import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Profile

final class AOSUserProfileTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize in-memory storage manager context
        try manager.initializeContainer(with: [User.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Level Threshold Math Test
    func testLevelCalculation() {
        let user = User(totalXP: 0)
        XCTAssertEqual(user.level, 1)
        
        // XP = 100 * (Level)^1.5. If level = 2, target XP = 100 * 2.82 = 282 XP
        user.totalXP = 300
        XCTAssertEqual(user.level, 2)
        
        // If level = 5, target XP = 100 * 11.18 = 1118 XP
        user.totalXP = 1200
        XCTAssertEqual(user.level, 5)
    }
    
    // MARK: - SwiftData Repository Operations
    func testRepositoryCRUD() throws {
        let repository = AOSUserRepository(storageManager: manager)
        let userId = UUID()
        let testUser = User(
            id: userId,
            displayName: "Rohan",
            currentStage: 1,
            transformationIndexScore: 34.0,
            totalXP: 100
        )
        
        // Save
        try repository.saveUser(testUser)
        
        // Fetch
        let fetchedUser = try repository.fetchUser(byId: userId)
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?.displayName, "Rohan")
        XCTAssertEqual(fetchedUser?.transformationIndexScore, 34.0)
        XCTAssertEqual(fetchedUser?.syncState, 2) // Pending Update
        
        // Update XP / Stats Level Up
        let updatedUser = try repository.incrementUserXP(amount: 150, attribute: "INT", onUser: userId)
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.totalXP, 250)
        XCTAssertEqual(updatedUser?.intelligenceStat, 2) // Level up from 1 to 2
        
        // Delete (Soft Delete)
        try repository.deleteUser(testUser)
        let deletedUser = try repository.fetchUser(byId: userId)
        XCTAssertNotNil(deletedUser)
        XCTAssertTrue(deletedUser?.isDeleted ?? false)
        XCTAssertEqual(deletedUser?.syncState, 3) // Pending Delete
    }
}
