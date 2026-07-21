import Foundation
import Observation
import Models
import Repositories
import Common

@Observable
public final class AdvancedFinanceViewModel {
    public var state: AdvancedFinanceState = .idle
    
    public var transactions: [AdvancedTransaction] = []
    public var savingsGoals: [SavingsGoal] = []
    public var fixedDeposits: [FixedDeposit] = []
    public var investments: [AssetInvestment] = []
    public var loans: [DebtLoan] = []
    public var budgets: [BudgetLimit] = []
    
    private let financeRepository: AdvancedFinanceRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(financeRepository: AdvancedFinanceRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.financeRepository = financeRepository
        self.userRepository = userRepository
    }
    
    public func loadAllData(forUser userId: UUID) {
        state = .loading
        do {
            var fetchedTransactions = try financeRepository.fetchTransactions(forUser: userId)
            if fetchedTransactions.isEmpty {
                let initialTx = generateDefaultTransactions(userId: userId)
                for tx in initialTx {
                    try financeRepository.saveTransaction(tx)
                }
                fetchedTransactions = initialTx
            }
            self.transactions = fetchedTransactions
            
            var fetchedGoals = try financeRepository.fetchSavingsGoals(forUser: userId)
            if fetchedGoals.isEmpty {
                let initialGoals = generateDefaultGoals(userId: userId)
                for goal in initialGoals {
                    try financeRepository.saveSavingsGoal(goal)
                }
                fetchedGoals = initialGoals
            }
            self.savingsGoals = fetchedGoals
            
            var fetchedFDs = try financeRepository.fetchFixedDeposits(forUser: userId)
            if fetchedFDs.isEmpty {
                let initialFD = FixedDeposit(userId: userId, bankName: "SBI bank", principal: 10000.0, interestRate: 7.2, tenureMonths: 12)
                try financeRepository.saveFixedDeposit(initialFD)
                fetchedFDs = [initialFD]
            }
            self.fixedDeposits = fetchedFDs
            
            var fetchedInvestments = try financeRepository.fetchInvestments(forUser: userId)
            if fetchedInvestments.isEmpty {
                let initialAssets = [
                    AssetInvestment(userId: userId, assetName: "Apple Inc (AAPL)", assetType: "Stock", buyPrice: 150.0, quantity: 10.0, currentPrice: 185.0),
                    AssetInvestment(userId: userId, assetName: "Nifty 50 Index Fund", assetType: "Mutual Fund", buyPrice: 120.0, quantity: 50.0, currentPrice: 135.0)
                ]
                for asset in initialAssets {
                    try financeRepository.saveInvestment(asset)
                }
                fetchedInvestments = initialAssets
            }
            self.investments = fetchedInvestments
            
            var fetchedLoans = try financeRepository.fetchLoans(forUser: userId)
            if fetchedLoans.isEmpty {
                let initialLoan = DebtLoan(userId: userId, loanName: "HDFC Home Loan", principal: 50000.0, interestRate: 8.5, tenureMonths: 240, remainingBalance: 48000.0)
                try financeRepository.saveLoan(initialLoan)
                fetchedLoans = [initialLoan]
            }
            self.loans = fetchedLoans
            
            var fetchedBudgets = try financeRepository.fetchBudgets(forUser: userId)
            if fetchedBudgets.isEmpty {
                let initialBudgets = [
                    BudgetLimit(userId: userId, category: "Variable Expense", monthlyLimit: 1200.0),
                    BudgetLimit(userId: userId, category: "Fixed Expense", monthlyLimit: 2000.0)
                ]
                for b in initialBudgets {
                    try financeRepository.saveBudget(b)
                }
                fetchedBudgets = initialBudgets
            }
            self.budgets = fetchedBudgets
            
            state = .loaded
        } catch {
            state = .failure("Unable to load financial databases: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Transaction loggers
    public func addTransaction(descr: String, amount: Double, category: String, notes: String, forUser userId: UUID, completion: @escaping (Bool) -> Void) {
        let tx = AdvancedTransaction(userId: userId, descr: descr, amount: amount, category: category, notes: notes)
        
        do {
            try financeRepository.saveTransaction(tx)
            
            // Check budget violations
            if category.contains("Expense") {
                let currentSpent = transactions.filter({ $0.category == category }).reduce(0.0) { $0 + $1.amount } + amount
                if let budget = budgets.first(where: { $0.category == category }), currentSpent > budget.monthlyLimit {
                    AOSNotificationManager.shared.scheduleLowRunwayAlert(months: survivalRunwayMonths)
                }
            }
            
            // Award +10 XP for logging ledgers
            _ = try userRepository.incrementUserXP(amount: 10, attribute: "FOR", onUser: userId)
            
            loadAllData(forUser: userId)
            completion(true)
        } catch {
            state = .failure("Failed to save transaction: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Core Math Calculations
    public var totalCapitalReserves: Double {
        let fdReserves = fixedDeposits.reduce(0.0) { $0 + $1.principal }
        let cashReserves = transactions.filter({ $0.category == "Salary" || $0.category == "Income" }).reduce(0.0) { $0 + $1.amount } - transactions.filter({ $0.category.contains("Expense") }).reduce(0.0) { $0 + $1.amount }
        // Base seed cash + logs
        return 12000.0 + cashReserves + fdReserves
    }
    
    public var monthlyBurn: Double {
        let expenses = transactions.filter { $0.category == "Fixed Expense" || $0.category == "Variable Expense" }
        return expenses.reduce(0.0) { $0 + $1.amount }
    }
    
    public var survivalRunwayMonths: Double {
        let burn = monthlyBurn
        if burn <= 0 { return 99.0 }
        return totalCapitalReserves / burn
    }
    
    public var investmentPortfolioValue: Double {
        investments.reduce(0.0) { $0 + ($1.currentPrice * $1.quantity) }
    }
    
    public var investmentNetGains: Double {
        investments.reduce(0.0) { $0 + (($1.currentPrice - $1.buyPrice) * $1.quantity) }
    }
    
    // MARK: - EMI Calculator Formula
    public func calculateEMI(principal: Double, annualRate: Double, tenureMonths: Int) -> Double {
        guard principal > 0, annualRate > 0, tenureMonths > 0 else { return 0.0 }
        let monthlyRate = (annualRate / 12.0) / 100.0
        let numerator = principal * monthlyRate * pow(1.0 + monthlyRate, Double(tenureMonths))
        let denominator = pow(1.0 + monthlyRate, Double(tenureMonths)) - 1.0
        return numerator / denominator
    }
    
    // MARK: - Export Data CSV Format
    public func buildCSVText() -> String {
        var csvString = "Date,Description,Amount,Category,Notes\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for tx in transactions {
            let dateStr = formatter.string(from: tx.createdAt)
            csvString += "\(dateStr),\"\(tx.descr)\",\(tx.amount),\(tx.category),\"\(tx.notes)\"\n"
        }
        return csvString
    }
    
    // MARK: - Defaults
    private func generateDefaultTransactions(userId: UUID) -> [AdvancedTransaction] {
        return [
            AdvancedTransaction(userId: userId, descr: "Software Engineer Salary", amount: 4500.0, category: "Salary", notes: "AOS Core Tech Corp"),
            AdvancedTransaction(userId: userId, descr: "Co-working Space Rent", amount: 1500.0, category: "Fixed Expense", notes: "Monthly workspace"),
            AdvancedTransaction(userId: userId, descr: "Cloud Host Services", amount: 350.0, category: "Variable Expense", notes: "AWS dev nodes")
        ]
    }
    
    private func generateDefaultGoals(userId: UUID) -> [SavingsGoal] {
        return [
            SavingsGoal(userId: userId, goalName: "Startup Seed Fund", targetAmount: 25000.0, currentSavings: 15000.0)
        ]
    }
}
