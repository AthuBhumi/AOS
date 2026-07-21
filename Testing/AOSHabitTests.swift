import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Habits

final class AOSHabitTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and Habit schemas
        try manager.initializeContainer(with: [User.self, Habit.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Habits Streak & Compliance Logic Tests
    func testHabitsStreakAndComplianceCalculations() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let habitRepo = AOSHabitRepository(storageManager: manager)
        let viewModel = HabitViewModel(habitRepository: habitRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        let habitId = UUID()
        let testHabit = Habit(
            id: habitId,
            userId: userId,
            title: "Java Coding Practice",
            cueText: "After study focus block",
            responseText: "Solve 1 DSA challenge",
            rewardText: "XP points",
            activeStreak: 0,
            completionHistory: []
        )
        try habitRepo.saveHabit(testHabit)
        
        // Log Day 1 (Yesterday completion)
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = today.addingTimeInterval(-86400)
        testHabit.completionHistory.append(yesterday)
        testHabit.activeStreak = 1
        try habitRepo.saveHabit(testHabit)
        
        viewModel.loadHabits(forUser: userId)
        
        guard case .loaded(let list) = viewModel.state else {
            XCTFail("State not loaded")
            return
        }
        
        XCTAssertEqual(list.count, 1)
        let loadedHabit = list[0]
        XCTAssertEqual(loadedHabit.activeStreak, 1)
        
        // Check off today: succeeds, increments streak to 2, awards +10 XP
        let checkExpectation = self.expectation(description: "Check off habit today succeeds")
        viewModel.checkOffHabit(habitId: habitId, forUser: userId) { success in
            XCTAssertTrue(success)
            checkExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // Verify streak
        let updatedHabit = try habitRepo.fetchHabits(forUser: userId).first
        XCTAssertEqual(updatedHabit?.activeStreak, 2)
        
        // Verify XP updates
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 110)
        XCTAssertEqual(updatedUser?.strengthStat, 2) // Stats incremented
        
        // Verify Compliance rate: 2 completed days out of 30 = 6.66%
        let rate = viewModel.getComplianceRate(updatedHabit!)
        XCTAssertEqual(rate, (2.0 / 30.0) * 100.0, accuracy: 0.1)
    }
}
