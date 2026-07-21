import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSFinanceRepository: FinanceRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSFinanceRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchTransactions(forUser userId: UUID) throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch Transactions: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveTransaction(_ transaction: Transaction) throws {
        context.insert(transaction)
        transaction.incrementClock()
        transaction.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func fetchAccounts(forUser userId: UUID) throws -> [FinancialAccount] {
        let descriptor = FetchDescriptor<FinancialAccount>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch FinancialAccounts: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveAccount(_ account: FinancialAccount) throws {
        context.insert(account)
        account.incrementClock()
        account.syncState = 2 // Pending Update
        try storageManager.save()
    }
}
