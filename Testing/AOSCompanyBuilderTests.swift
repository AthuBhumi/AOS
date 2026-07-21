import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Company

final class AOSCompanyBuilderTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and Company Builder schemas
        try manager.initializeContainer(
            with: [
                User.self,
                Company.self,
                Employee.self,
                CompanyProject.self,
                Invoice.self,
                SOP.self
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
    
    // MARK: - Corporate KPIs Mathematics Validation Tests
    func testCompanyKPIsAndReports() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let companyRepo = AOSCompanyBuilderRepository(storageManager: manager)
        let viewModel = CompanyBuilderViewModel(companyRepo: companyRepo, userRepository: userRepo)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        let company = Company(userId: userId, name: "Productivity Inc", revenue: 10000.0, expenses: 4000.0)
        
        // 1 Employee (attendance = 15 days out of 20 = 75% attendance)
        let emp = Employee(name: "Aman", role: "Dev", department: "Engineering", salary: 3000.0, attendanceDays: 15)
        company.employees = [emp]
        
        // 2 Projects: 1 completed, 1 pending. Progress = 50%
        let p1 = CompanyProject(title: "Task 1", status: "Done", company: company)
        let p2 = CompanyProject(title: "Task 2", status: "To Do", company: company)
        company.projects = [p1, p2]
        
        // 1 Unpaid client invoice
        let inv = Invoice(clientName: "Client A", amount: 2000.0, isPaid: false, company: company)
        company.invoices = [inv]
        
        try companyRepo.saveCompany(company)
        
        viewModel.loadCompanies(forUser: userId)
        
        // 1. Verify Project Progress: 1/2 Done = 50%
        let progress = viewModel.getProjectProgress(forCompany: company)
        XCTAssertEqual(progress, 50.0)
        
        // 2. Verify Employee Productivity: 15/20 days = 75%
        let productivity = viewModel.getEmployeeProductivity(forCompany: company)
        XCTAssertEqual(productivity, 75.0)
        
        // 3. Verify Profit Margin: (10k - 4k) / 10k = 60%
        let profit = viewModel.getProfitMargin(forCompany: company)
        XCTAssertEqual(profit, 60.0)
        
        // 4. Verify Health Score: (50 * 0.4) + (60 * 0.4) + (75 * 0.2) = 20 + 24 + 15 = 59.0%
        let health = viewModel.getCompanyHealthScore(forCompany: company)
        XCTAssertEqual(health, 59.0)
        
        // 5. Verify AI report compilation formatting
        let advisorVM = AICompanyAdvisorViewModel()
        advisorVM.compileWeeklyManagementReport(forCompany: company, healthScore: health, progress: progress, profitMargin: profit)
        XCTAssertTrue(advisorVM.weeklyReportText.contains("Productivity Inc"))
        XCTAssertTrue(advisorVM.weeklyReportText.contains("Corporate Health Score: 59.0%"))
        XCTAssertTrue(advisorVM.weeklyReportText.contains("Accounts Receivable Alert: $2000"))
    }
}
