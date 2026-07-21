import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Finance

final class AOSAdvancedFinanceTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and Advanced Finance schemas
        try manager.initializeContainer(
            with: [
                User.self,
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
    
    // MARK: - Core EMI Mathematics Validation Tests
    func testEMICalculatorFormula() {
        let userRepo = AOSUserRepository(storageManager: manager)
        let financeRepo = AOSAdvancedFinanceRepository(storageManager: manager)
        let viewModel = AdvancedFinanceViewModel(financeRepository: financeRepo, userRepository: userRepo)
        
        // P = $10,000, Annual Rate = 12% (1% monthly), tenure = 12 months
        let emi = viewModel.calculateEMI(principal: 10000.0, annualRate: 12.0, tenureMonths: 12)
        
        // Target EMI using standard math: $888.49
        XCTAssertEqual(emi, 888.49, accuracy: 0.1)
    }
    
    // MARK: - Net Worth & Runway Projections Database Validation
    func testNetWorthAndCSVBuilder() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let financeRepo = AOSAdvancedFinanceRepository(storageManager: manager)
        let viewModel = AdvancedFinanceViewModel(financeRepository: financeRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        // Seed Stock Holding (AAPL: 10 shares buy price $150, current price $180)
        let stock = AssetInvestment(userId: userId, assetName: "AAPL", assetType: "Stock", buyPrice: 150.0, quantity: 10.0, currentPrice: 180.0)
        try financeRepo.saveInvestment(stock)
        
        // Seed Fixed Deposit ($5,000 principal)
        let fd = FixedDeposit(userId: userId, bankName: "SBI", principal: 5000.0, interestRate: 6.5, tenureMonths: 12)
        try financeRepo.saveFixedDeposit(fd)
        
        // Seed Transactions: Rent $1,500
        let tx = AdvancedTransaction(userId: userId, descr: "Rent", amount: 1500.0, category: "Fixed Expense")
        try financeRepo.saveTransaction(tx)
        
        viewModel.loadAllData(forUser: userId)
        
        // Net reserves cash calculation: $12k base + $5k FD - $1.5k Rent = $15.5k
        XCTAssertEqual(viewModel.totalCapitalReserves, 15500.0)
        
        // Asset portfolio value: 10 * 180 = $1800
        XCTAssertEqual(viewModel.investmentPortfolioValue, 1800.0)
        
        // Asset net gains: 10 * (180 - 150) = +$300
        XCTAssertEqual(viewModel.investmentNetGains, 300.0)
        
        // Monthly burn = $1500
        XCTAssertEqual(viewModel.monthlyBurn, 1500.0)
        
        // Runway calculation: $15.5k Reserves / $1.5k Burn = 10.33 months
        XCTAssertEqual(viewModel.survivalRunwayMonths, 10.33, accuracy: 0.1)
        
        // Verify CSV text compilation content
        let csv = viewModel.buildCSVText()
        XCTAssertTrue(csv.contains("Rent"))
        XCTAssertTrue(csv.contains("Fixed Expense"))
    }
}
