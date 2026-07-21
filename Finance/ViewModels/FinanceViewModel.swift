import Foundation
import Observation
import Models
import Repositories

@Observable
public final class FinanceViewModel {
    public var state: FinanceState = .idle
    public var transactions: [Transaction] = []
    public var accounts: [FinancialAccount] = []
    
    private let financeRepository: FinanceRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(financeRepository: FinanceRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.financeRepository = financeRepository
        self.userRepository = userRepository
    }
    
    public func loadFinanceData(forUser userId: UUID) {
        state = .loading
        do {
            var fetchedAccounts = try financeRepository.fetchAccounts(forUser: userId)
            if fetchedAccounts.isEmpty {
                let initialAccounts = generateDefaultAccounts(userId: userId)
                for account in initialAccounts {
                    try financeRepository.saveAccount(account)
                }
                fetchedAccounts = initialAccounts
            }
            self.accounts = fetchedAccounts
            
            var fetchedTransactions = try financeRepository.fetchTransactions(forUser: userId)
            if fetchedTransactions.isEmpty {
                let initialTx = generateDefaultTransactions(userId: userId)
                for tx in initialTx {
                    try financeRepository.saveTransaction(tx)
                }
                fetchedTransactions = initialTx
            }
            self.transactions = fetchedTransactions
            state = .loaded
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func addTransaction(descr: String, amount: Double, category: String, forUser userId: UUID, completion: @escaping (Bool) -> Void) {
        let transaction = Transaction(userId: userId, descr: descr, amount: amount, category: category)
        
        do {
            try financeRepository.saveTransaction(transaction)
            
            // Adjust Cash Account balance automatically based on transaction category
            if let cashAccount = accounts.first(where: { $0.type == "Cash" }) {
                if category == "Income" {
                    cashAccount.balance += amount
                } else {
                    cashAccount.balance -= amount
                }
                try financeRepository.saveAccount(cashAccount)
            }
            
            // Award +10 XP for logging ledgers
            _ = try userRepository.incrementUserXP(amount: 10, attribute: "FOR", onUser: userId)
            
            loadFinanceData(forUser: userId)
            completion(true)
        } catch {
            state = .failure("Transaction write failed: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Runway & Burn Rate Computations
    public var totalCash: Double {
        accounts.filter { $0.type == "Cash" }.reduce(0.0) { $0 + $1.balance }
    }
    
    public var monthlyBurn: Double {
        // Sums Fixed and Variable expenses in history
        let expenses = transactions.filter { $0.category == "Fixed Expense" || $0.category == "Variable Expense" }
        return expenses.reduce(0.0) { $0 + $1.amount }
    }
    
    public var survivalRunwayMonths: Double {
        let burn = monthlyBurn
        if burn <= 0 { return 99.0 } // Safe/Infinite runway
        return totalCash / burn
    }
    
    public var isRunwayHazard: Bool {
        return survivalRunwayMonths < 6.0
    }
    
    private func generateDefaultAccounts(userId: UUID) -> [FinancialAccount] {
        return [
            FinancialAccount(userId: userId, name: "Checking Account", balance: 12000.0, type: "Cash"),
            FinancialAccount(userId: userId, name: "Investment Account", balance: 5000.0, type: "Investment")
        ]
    }
    
    private func generateDefaultTransactions(userId: UUID) -> [Transaction] {
        return [
            Transaction(userId: userId, descr: "Monthly Rent", amount: 1500.0, category: "Fixed Expense"),
            Transaction(userId: userId, descr: "Food & Groceries", amount: 500.0, category: "Variable Expense")
        ]
    }
}
