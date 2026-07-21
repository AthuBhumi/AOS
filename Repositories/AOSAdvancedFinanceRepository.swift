import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSAdvancedFinanceRepository: AdvancedFinanceRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSAdvancedFinanceRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchTransactions(forUser userId: UUID) throws -> [AdvancedTransaction] {
        let desc = FetchDescriptor<AdvancedTransaction>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        return try context.fetch(desc)
    }
    
    public func saveTransaction(_ transaction: AdvancedTransaction) throws {
        context.insert(transaction)
        transaction.incrementClock()
        transaction.syncState = 2
        try storageManager.save()
    }
    
    public func fetchSavingsGoals(forUser userId: UUID) throws -> [SavingsGoal] {
        let desc = FetchDescriptor<SavingsGoal>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted }
        )
        return try context.fetch(desc)
    }
    
    public func saveSavingsGoal(_ goal: SavingsGoal) throws {
        context.insert(goal)
        goal.incrementClock()
        goal.syncState = 2
        try storageManager.save()
    }
    
    public func fetchFixedDeposits(forUser userId: UUID) throws -> [FixedDeposit] {
        let desc = FetchDescriptor<FixedDeposit>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted }
        )
        return try context.fetch(desc)
    }
    
    public func saveFixedDeposit(_ fd: FixedDeposit) throws {
        context.insert(fd)
        fd.incrementClock()
        fd.syncState = 2
        try storageManager.save()
    }
    
    public func fetchInvestments(forUser userId: UUID) throws -> [AssetInvestment] {
        let desc = FetchDescriptor<AssetInvestment>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted }
        )
        return try context.fetch(desc)
    }
    
    public func saveInvestment(_ asset: AssetInvestment) throws {
        context.insert(asset)
        asset.incrementClock()
        asset.syncState = 2
        try storageManager.save()
    }
    
    public func fetchLoans(forUser userId: UUID) throws -> [DebtLoan] {
        let desc = FetchDescriptor<DebtLoan>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted }
        )
        return try context.fetch(desc)
    }
    
    public func saveLoan(_ loan: DebtLoan) throws {
        context.insert(loan)
        loan.incrementClock()
        loan.syncState = 2
        try storageManager.save()
    }
    
    public func fetchBudgets(forUser userId: UUID) throws -> [BudgetLimit] {
        let desc = FetchDescriptor<BudgetLimit>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted }
        )
        return try context.fetch(desc)
    }
    
    public func saveBudget(_ budget: BudgetLimit) throws {
        context.insert(budget)
        budget.incrementClock()
        budget.syncState = 2
        try storageManager.save()
    }
}
