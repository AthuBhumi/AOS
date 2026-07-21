import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Goals

final class AOSGoalTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User, Goal, and KeyResult schemas
        try manager.initializeContainer(with: [User.self, Goal.self, KeyResult.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - OKR Progress Percentage Calculations Tests
    func testOKRProgressCalculations() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let goalRepo = AOSGoalRepository(storageManager: manager)
        let viewModel = GoalViewModel(goalRepository: goalRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        let goalId = UUID()
        let goal = Goal(
            id: goalId,
            userId: userId,
            title: "Build MVP",
            category: "Skill",
            progress: 0.0
        )
        
        let kr1Id = UUID()
        let kr2Id = UUID()
        let results = [
            KeyResult(id: kr1Id, title: "Create database", isCompleted: false, goal: goal),
            KeyResult(id: kr2Id, title: "Establish APIs", isCompleted: false, goal: goal)
        ]
        
        goal.keyResults = results
        try goalRepo.saveGoal(goal)
        
        viewModel.loadGoals(forUser: userId)
        
        guard case .loaded(let list) = viewModel.state else {
            XCTFail("State not loaded")
            return
        }
        
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list[0].progress, 0.0)
        
        // Toggle Key Result 1: progress updates to 50.0%, awards +30 XP
        let toggleExpectation1 = self.expectation(description: "Toggle KeyResult 1 succeeds")
        viewModel.toggleKeyResult(goalId: goalId, keyResultId: kr1Id, forUser: userId) { success in
            XCTAssertTrue(success)
            toggleExpectation1.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        let updatedGoal1 = try goalRepo.fetchGoals(forUser: userId).first
        XCTAssertEqual(updatedGoal1?.progress, 50.0)
        
        let updatedUser1 = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser1?.totalXP, 130)
        
        // Toggle Key Result 2: progress updates to 100.0%, awards +30 XP (toggled) + 100 XP (completion)
        let toggleExpectation2 = self.expectation(description: "Toggle KeyResult 2 completes goal")
        viewModel.toggleKeyResult(goalId: goalId, keyResultId: kr2Id, forUser: userId) { success in
            XCTAssertTrue(success)
            toggleExpectation2.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        let updatedGoal2 = try goalRepo.fetchGoals(forUser: userId).first
        XCTAssertEqual(updatedGoal2?.progress, 100.0)
        
        let updatedUser2 = try userRepo.fetchUser(byId: userId)
        // 100 base + 30 (kr1) + 30 (kr2) + 100 (goal completion bonus) = 260 XP
        XCTAssertEqual(updatedUser2?.totalXP, 260)
        XCTAssertEqual(updatedUser2?.charismaStat, 3) // level up stats
    }
}
