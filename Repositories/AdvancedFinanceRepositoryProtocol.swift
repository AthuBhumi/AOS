import Foundation
import Models

public protocol AdvancedFinanceRepositoryProtocol {
    func fetchTransactions(forUser userId: UUID) throws -> [AdvancedTransaction]
    func saveTransaction(_ transaction: AdvancedTransaction) throws
    
    func fetchSavingsGoals(forUser userId: UUID) throws -> [SavingsGoal]
    func saveSavingsGoal(_ goal: SavingsGoal) throws
    
    func fetchFixedDeposits(forUser userId: UUID) throws -> [FixedDeposit]
    func saveFixedDeposit(_ fd: FixedDeposit) throws
    
    func fetchInvestments(forUser userId: UUID) throws -> [AssetInvestment]
    func saveInvestment(_ asset: AssetInvestment) throws
    
    func fetchLoans(forUser userId: UUID) throws -> [DebtLoan]
    func saveLoan(_ loan: DebtLoan) throws
    
    func fetchBudgets(forUser userId: UUID) throws -> [BudgetLimit]
    func saveBudget(_ budget: BudgetLimit) throws
}
