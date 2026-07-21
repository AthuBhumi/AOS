import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Finance

final class AOSFinanceTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User, Transaction, and FinancialAccount schemas
        try manager.initializeContainer(with: [User.self, Transaction.self, FinancialAccount.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Survival Runway Calculations Tests
    func testRunwayAndBurnRateCalculations() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let financeRepo = AOSFinanceRepository(storageManager: manager)
        let viewModel = FinanceViewModel(financeRepository: financeRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        // Initial setup: checking account balance = $12,000
        let account = FinancialAccount(userId: userId, name: "Checking Account", balance: 12000.0, type: "Cash")
        try financeRepo.saveAccount(account)
        
        // Setup initial transactions: fixed rent = $1,500, variable food = $500. Total burn = $2,000
        let tx1 = Transaction(userId: userId, descr: "Rent", amount: 1500.0, category: "Fixed Expense")
        let tx2 = Transaction(userId: userId, descr: "Food", amount: 500.0, category: "Variable Expense")
        try financeRepo.saveTransaction(tx1)
        try financeRepo.saveTransaction(tx2)
        
        viewModel.loadFinanceData(forUser: userId)
        
        XCTAssertEqual(viewModel.totalCash, 12000.0)
        XCTAssertEqual(viewModel.monthlyBurn, 2000.0)
        
        // Verify Runway: Cash $12k / Burn $2k = 6.0 months
        XCTAssertEqual(viewModel.survivalRunwayMonths, 6.0)
        XCTAssertFalse(viewModel.isRunwayHazard)
        
        // Add new Variable Expense of $500 (burn increases to $2,500, cash balance updates to $11,500)
        let txExpectation = self.expectation(description: "New transaction is saved")
        viewModel.addTransaction(descr: "Shopping", amount: 500.0, category: "Variable Expense", forUser: userId) { success in
            XCTAssertTrue(success)
            txExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        XCTAssertEqual(viewModel.totalCash, 11500.0)
        XCTAssertEqual(viewModel.monthlyBurn, 2500.0)
        
        // Verify updated Runway: $11,500 / $2,500 = 4.6 months
        XCTAssertEqual(viewModel.survivalRunwayMonths, 4.6)
        // Runway is under 6 months -> Hazard flag is active!
        XCTAssertTrue(viewModel.isRunwayHazard)
        
        // Verify User XP updates (+10 XP awarded for logging transaction)
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 110)
        XCTAssertEqual(updatedUser?.fortuneStat, 2) // Stats incremented
    }
}
