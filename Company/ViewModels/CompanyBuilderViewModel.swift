import Foundation
import Observation
import Models
import Repositories

@Observable
public final class CompanyBuilderViewModel {
    public var state: CompanyBuilderState = .idle
    public var companies: [Company] = []
    
    private let companyRepo: CompanyBuilderRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(companyRepo: CompanyBuilderRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.companyRepo = companyRepo
        self.userRepository = userRepository
    }
    
    public func loadCompanies(forUser userId: UUID) {
        state = .loading
        do {
            var list = try companyRepo.fetchCompanies(forUser: userId)
            
            // Seed a default company if empty
            if list.isEmpty {
                let initial = generateDefaultCompany(userId: userId)
                try companyRepo.saveCompany(initial)
                list = [initial]
            }
            
            self.companies = list
            state = .loaded
        } catch {
            state = .failure("Unable to fetch company lists: \(error.localizedDescription)")
        }
    }
    
    public func createNewCompany(name: String, forUser userId: UUID) {
        let company = Company(userId: userId, name: name)
        
        // Seed standard departments guidelines
        company.sops = [
            SOP(title: "Engineering SOP", policyText: "All PRs require 1 peer review and passing mock compilations.", company: company),
            SOP(title: "Information Security Policy", policyText: "Encrypt all locally stored persistent files with SQLCipher keys.", company: company)
        ]
        
        do {
            try companyRepo.saveCompany(company)
            loadCompanies(forUser: userId)
        } catch {
            state = .failure("Failed to save company: \(error.localizedDescription)")
        }
    }
    
    public func commitCompanyDetails(company: Company, forUser userId: UUID) {
        company.updatedAt = Date()
        do {
            try companyRepo.saveCompany(company)
            
            // Award +50 XP for details edits
            _ = try userRepository.incrementUserXP(amount: 50, attribute: "CHA", onUser: userId)
            
            loadCompanies(forUser: userId)
        } catch {
            state = .failure("Failed to save company detail: \(error.localizedDescription)")
        }
    }
    
    public func updateProjectStatus(companyId: UUID, projectId: UUID, status: String, forUser userId: UUID) {
        guard let company = companies.first(where: { $0.id == companyId }) else { return }
        guard let project = company.projects.first(where: { $0.id == projectId }) else { return }
        
        project.status = status
        
        do {
            try companyRepo.saveCompany(company)
            
            // If project is completed (Done), award +30 XP
            if status == "Done" {
                _ = try userRepository.incrementUserXP(amount: 30, attribute: "STR", onUser: userId)
            }
            
            loadCompanies(forUser: userId)
        } catch {
            state = .failure("Failed to update project status: \(error.localizedDescription)")
        }
    }
    
    public func toggleInvoicePayment(companyId: UUID, invoiceId: UUID, forUser userId: UUID) {
        guard let company = companies.first(where: { $0.id == companyId }) else { return }
        guard let invoice = company.invoices.first(where: { $0.id == invoiceId }) else { return }
        
        invoice.isCompleted.toggle() // toggling payment
        
        if invoice.isCompleted {
            company.revenue += invoice.amount
        } else {
            company.revenue -= invoice.amount
        }
        
        do {
            try companyRepo.saveCompany(company)
            
            // Award +20 XP for paid invoice
            if invoice.isCompleted {
                _ = try userRepository.incrementUserXP(amount: 20, attribute: "FOR", onUser: userId)
            }
            
            loadCompanies(forUser: userId)
        } catch {
            state = .failure("Failed to update invoice: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Corporate Analytics Calculators
    public func getProjectProgress(forCompany company: Company) -> Double {
        if company.projects.isEmpty { return 0.0 }
        let completed = company.projects.filter { $0.status == "Done" }.count
        return (Double(completed) / Double(company.projects.count)) * 100.0
    }
    
    public func getEmployeeProductivity(forCompany company: Company) -> Double {
        if company.employees.isEmpty { return 100.0 }
        // Attendance compliance: average attendance rate (max 20 days per month)
        let totalAttend = company.employees.reduce(0) { $0 + $1.attendanceDays }
        let maxPossible = company.employees.count * 20
        return (Double(totalAttend) / Double(maxPossible)) * 100.0
    }
    
    public func getProfitMargin(forCompany company: Company) -> Double {
        let profit = company.revenue - company.expenses
        if company.revenue <= 0 { return 0.0 }
        return (profit / company.revenue) * 100.0
    }
    
    public func getCompanyHealthScore(forCompany company: Company) -> Double {
        // Project Progress (40%) + Profit Margin weight (40%) + Attendance compliance (20%)
        let progress = getProjectProgress(forCompany: company)
        let profit = min(100.0, max(0.0, getProfitMargin(forCompany: company)))
        let attendance = getEmployeeProductivity(forCompany: company)
        return (progress * 0.4) + (profit * 0.4) + (attendance * 0.2)
    }
    
    private func generateDefaultCompany(userId: UUID) -> Company {
        let company = Company(
            userId: userId,
            name: "Atharva Technologies Pvt Ltd",
            revenue: 55000.0,
            expenses: 12000.0
        )
        
        company.employees = [
            Employee(name: "Rohan Sen", role: "iOS Dev", department: "Engineering", salary: 3500.0, attendanceDays: 18),
            Employee(name: "Neha Joshi", role: "UX Designer", department: "Engineering", salary: 2800.0, attendanceDays: 19)
        ]
        
        company.projects = [
            CompanyProject(title: "SwiftData Encryption Schema migration", status: "Done", company: company),
            CompanyProject(title: "Establish REST endpoints compile client", status: "In Progress", company: company),
            CompanyProject(title: "Integrate SM-2 reading lists widgets", status: "To Do", company: company)
        ]
        
        company.invoices = [
            Invoice(clientName: "Enterprise Client Corp", amount: 15000.0, isPaid: true, company: company),
            Invoice(clientName: "Dev Incubator Hub", amount: 5000.0, isPaid: false, company: company)
        ]
        
        company.sops = [
            SOP(title: "SQLCipher database setup SOP", policyText: "Always call setupDefaultContainer before querying persistent database frames.", company: company)
        ]
        
        return company
    }
}
extension Invoice {
    var isCompleted: Bool {
        get { isPaid }
        set { isPaid = newValue }
    }
}
