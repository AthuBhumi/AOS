import Foundation
import SwiftData
import Core

@Model
public final class Transaction: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var descr: String
    public var amount: Double
    public var category: String // "Income", "Fixed Expense", "Variable Expense"
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, descr: String, amount: Double, category: String, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.descr = descr
        self.amount = amount
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
