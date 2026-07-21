import Foundation
import Models

public protocol FinanceRepositoryProtocol {
    func fetchTransactions(forUser userId: UUID) throws -> [Transaction]
    func saveTransaction(_ transaction: Transaction) throws
    func fetchAccounts(forUser userId: UUID) throws -> [FinancialAccount]
    func saveAccount(_ account: FinancialAccount) throws
}
