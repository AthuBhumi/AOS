import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Dashboard

final class AOSCEODashboardTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User, CEODecision, and other schemas
        try manager.initializeContainer(
            with: [
                User.self,
                CEODecision.self,
                StartupIdea.self,
                Company.self,
                AdvancedTransaction.self,
                SavingsGoal.self,
                FixedDeposit.self,
                AssetInvestment.self,
                DebtLoan.self,
                BudgetLimit.self
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
    
    // MARK: - Executive Scores Aggregators Mathematics Validation Tests
    func testCEOScorersAndCSVReports() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let companyRepo = AOSCompanyBuilderRepository(storageManager: manager)
        let businessRepo = AOSBusinessBuilderRepository(storageManager: manager)
        let financeRepo = AOSAdvancedFinanceRepository(storageManager: manager)
        let decisionRepo = AOSCEODecisionRepository(storageManager: manager)
        
        // Setup mock view model inject targets
        let viewModel = CEODashboardViewModel(
            decisionRepo: decisionRepo,
            userRepo: userRepo,
            companyRepo: companyRepo,
            businessRepo: businessRepo,
            financeRepo: financeRepo,
            habitRepo: AOSHabitRepository(storageManager: manager), // Mock representation
            goalRepo: AOSGoalRepository(storageManager: manager) // Mock representation
        )
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva CEO", totalXP: 120)
        testUser.intelligenceStat = 4
        testUser.strengthStat = 3
        testUser.charismaStat = 5
        try userRepo.saveUser(testUser)
        
        // Seed Decisions
        let dec = CEODecision(userId: userId, title: "Raise Seed Fund Round", optionsList: "Yes, No")
        try decisionRepo.saveDecision(dec)
        
        viewModel.loadAllData(forUser: userId)
        
        // 1. Verify Life Balance Score: (4+3+5)/15 * 100 = 80%
        XCTAssertEqual(viewModel.lifeBalanceScore, 80.0)
        
        // 2. Verify Overall Score incorporates balance
        XCTAssertGreaterThan(viewModel.overallScore, 0.0)
        
        // 3. Verify CSV builds
        let csv = viewModel.compileCEOCSVReport()
        XCTAssertTrue(csv.contains("Life Balance Ratio"))
        
        // 4. Verify AI advisor compilation formats
        let advisor = AICEODecisionAdvisorViewModel()
        advisor.compileQuarterlyBusinessReview(
            overall: viewModel.overallScore,
            readiness: viewModel.founderReadiness,
            exec: viewModel.executionScore,
            leadership: viewModel.leadershipScore,
            balance: viewModel.lifeBalanceScore,
            runway: viewModel.runwayMonths
        )
        XCTAssertTrue(advisor.reportText.contains("CEO QUARTERLY EXECUTIVE REVIEW"))
        XCTAssertTrue(advisor.reportText.contains("Life Balance score: 80.0%"))
    }
}
