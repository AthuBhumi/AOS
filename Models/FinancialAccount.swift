import Foundation
import SwiftData
import Core

@Model
public final class FinancialAccount: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var name: String
    public var balance: Double
    public var type: String // "Cash", "Investment"
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, name: String, balance: Double, type: String, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.type = type
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
