import Foundation
import SwiftData
import Core

@Model
public final class AdvancedTransaction: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var descr: String
    public var amount: Double
    public var category: String // "Salary", "Income", "Fixed Expense", "Variable Expense"
    public var notes: String
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, descr: String, amount: Double, category: String, notes: String = "", createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.descr = descr
        self.amount = amount
        self.category = category
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class SavingsGoal: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var goalName: String
    public var targetAmount: Double
    public var currentSavings: Double
    public var targetDate: Date
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, goalName: String, targetAmount: Double, currentSavings: Double = 0.0, targetDate: Date = Date().addingTimeInterval(86400 * 365), createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.goalName = goalName
        self.targetAmount = targetAmount
        self.currentSavings = currentSavings
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class FixedDeposit: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var bankName: String
    public var principal: Double
    public var interestRate: Double // e.g. 7.5 for 7.5%
    public var tenureMonths: Int
    public var startDate: Date
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, bankName: String, principal: Double, interestRate: Double, tenureMonths: Int, startDate: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.bankName = bankName
        self.principal = principal
        self.interestRate = interestRate
        self.tenureMonths = tenureMonths
        self.startDate = startDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class AssetInvestment: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var assetName: String
    public var assetType: String // "Stock", "Mutual Fund"
    public var buyPrice: Double
    public var quantity: Double
    public var currentPrice: Double
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, assetName: String, assetType: String, buyPrice: Double, quantity: Double, currentPrice: Double, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.assetName = assetName
        self.assetType = assetType
        self.buyPrice = buyPrice
        self.quantity = quantity
        self.currentPrice = currentPrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class DebtLoan: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var loanName: String
    public var principal: Double
    public var interestRate: Double
    public var tenureMonths: Int
    public var remainingBalance: Double
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, loanName: String, principal: Double, interestRate: Double, tenureMonths: Int, remainingBalance: Double, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.loanName = loanName
        self.principal = principal
        self.interestRate = interestRate
        self.tenureMonths = tenureMonths
        self.remainingBalance = remainingBalance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class BudgetLimit: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var category: String
    public var monthlyLimit: Double
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, category: String, monthlyLimit: Double, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
