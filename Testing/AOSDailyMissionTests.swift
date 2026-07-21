import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import DailyMission

final class AOSDailyMissionTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and DailyMission schemas
        try manager.initializeContainer(with: [User.self, DailyMission.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Core Daily Mission Database Operations
    func testMissionCheckOff() throws {
        let missionRepository = AOSDailyMissionRepository(storageManager: manager)
        let missionId = UUID()
        let mission = DailyMission(
            id: missionId,
            title: "Study Java Concurrency",
            attribute: "INT",
            xpReward: 50,
            isCompleted: false
        )
        
        // Save
        try missionRepository.saveMission(mission)
        
        // Fetch
        let todayMissions = try missionRepository.fetchMissions(forDate: Date())
        XCTAssertEqual(todayMissions.count, 1)
        XCTAssertFalse(todayMissions.first?.isCompleted ?? true)
        
        // Complete
        let completed = try missionRepository.completeMission(byId: missionId)
        XCTAssertNotNil(completed)
        XCTAssertTrue(completed?.isCompleted ?? false)
    }
    
    // MARK: - Rewards Claim Eligibility Tests
    @MainActor
    func testClaimRewardEligibilityFlow() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let missionRepo = AOSDailyMissionRepository(storageManager: manager)
        let viewModel = DailyMissionViewModel(missionRepository: missionRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        // Load missions triggers automatic generation for Stage 1
        viewModel.loadMissions(forDate: Date(), stage: 1)
        
        guard case .loaded(let missions) = viewModel.state else {
            XCTFail("ViewModel state not loaded")
            return
        }
        XCTAssertEqual(missions.count, 3)
        XCTAssertFalse(viewModel.allMissionsCompleted)
        
        // Claim should fail since missions are incomplete
        let claimExpectation = self.expectation(description: "Restricted claim fails")
        viewModel.claimDailyReward(for: userId) { success in
            XCTAssertFalse(success)
            claimExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // Complete all missions
        for mission in missions {
            viewModel.toggleMission(id: mission.id)
        }
        
        XCTAssertTrue(viewModel.allMissionsCompleted)
        
        // Claim should now succeed and grant +150 XP
        let claimSuccessExpectation = self.expectation(description: "Successful claim awards XP")
        viewModel.claimDailyReward(for: userId) { success in
            XCTAssertTrue(success)
            claimSuccessExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 250) // 100 base + 150 reward
        XCTAssertTrue(viewModel.claimedToday)
    }
}
