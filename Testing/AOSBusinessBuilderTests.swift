import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Business

final class AOSBusinessBuilderTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and Business Builder schemas
        try manager.initializeContainer(
            with: [
                User.self,
                StartupIdea.self,
                StartupMilestone.self,
                ComplianceItem.self,
                PitchDeck.self,
                RiskRegistration.self
            ],
            isInMemory: true
        )
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Business Growth & Execution Score Validation Tests
    func testStartupScorersAndReports() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let businessRepo = AOSBusinessBuilderRepository(storageManager: manager)
        let viewModel = BusinessBuilderViewModel(businessRepo: businessRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        let idea = StartupIdea(userId: userId, title: "Productivity OS", targetMarket: "Developers")
        
        // Milestones: 1 completed, 1 pending
        let m1 = StartupMilestone(title: "Define MVP", isCompleted: true, startupIdea: idea)
        let m2 = StartupMilestone(title: "Deploy database", isCompleted: false, startupIdea: idea)
        idea.milestones = [m1, m2]
        
        // Compliance: 1 completed, 1 pending
        let c1 = ComplianceItem(itemText: "MSME Reg", category: "MSME", isCompleted: true, startupIdea: idea)
        let c2 = ComplianceItem(itemText: "GSTIN Reg", category: "GST", isCompleted: false, startupIdea: idea)
        idea.complianceItems = [c1, c2]
        
        // Canvas: 2 non-empty boxes (problem, solution)
        idea.problem = "Too many manual trackers"
        idea.solution = "Build an autonomous dashboard"
        
        // Risks: 1 risk with impact=4, prob=3. total = 12 / 25 = 48%
        let risk = RiskRegistration(descr: "Competitor locks", impact: 4, probability: 3, mitigation: "Use open source core", startupIdea: idea)
        idea.risks = [risk]
        
        try businessRepo.saveIdea(idea)
        
        viewModel.loadIdeas(forUser: userId)
        
        // 1. Verify Execution Score: 1/2 completed milestones = 50%
        let exec = viewModel.getExecutionScore(forIdea: idea)
        XCTAssertEqual(exec, 50.0)
        
        // 2. Verify Founder Readiness:
        // Canvas: 2/9 non-empty -> 11.11% * 50 = 11.11 points
        // Compliance: 1/2 completed -> 50% * 50 = 25 points
        // Total = 36.11 points
        let readiness = viewModel.getFounderReadiness(forIdea: idea)
        XCTAssertEqual(readiness, 36.11, accuracy: 0.1)
        
        // 3. Verify Risk Score: (4 * 3) / 25 * 100 = 48%
        let riskFactor = viewModel.getRiskScore(forIdea: idea)
        XCTAssertEqual(riskFactor, 48.0)
        
        // 4. Verify Business Growth Score: (exec * 0.6) + (readiness * 0.4) = 30 + 14.44 = 44.44%
        let growth = viewModel.getBusinessGrowthScore(forIdea: idea)
        XCTAssertEqual(growth, 44.44, accuracy: 0.1)
        
        // 5. Verify AI Report compiler output
        let mentorVM = AIBusinessMentorViewModel()
        mentorVM.compileWeeklyFounderReport(forIdea: idea, growthScore: growth, readinessScore: readiness, riskScore: riskFactor)
        XCTAssertTrue(mentorVM.weeklyReportText.contains("Productivity OS"))
        XCTAssertTrue(mentorVM.weeklyReportText.contains("Growth Score: 44.4%"))
        XCTAssertTrue(mentorVM.weeklyReportText.contains("Roadmap Execution is lagging"))
    }
}
