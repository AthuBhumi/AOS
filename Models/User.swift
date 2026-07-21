import Foundation
import SwiftData
import Core

@Model
public final class User: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var displayName: String?
    public var currentStage: Int
    public var transformationIndexScore: Double
    public var totalXP: Int
    public var strengthStat: Int
    public var intelligenceStat: Int
    public var charismaStat: Int
    public var fortuneStat: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), displayName: String? = nil, currentStage: Int = 1, transformationIndexScore: Double = 0.0, totalXP: Int = 0, strengthStat: Int = 1, intelligenceStat: Int = 1, charismaStat: Int = 1, fortuneStat: Int = 1, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.currentStage = currentStage
        self.transformationIndexScore = transformationIndexScore
        self.totalXP = totalXP
        self.strengthStat = strengthStat
        self.intelligenceStat = intelligenceStat
        self.charismaStat = charismaStat
        self.fortuneStat = fortuneStat
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
    
    /// Helper calculation mapping the level threshold: XP = 100 * (Level)^1.5.
    public var level: Int {
        let baseXP = Double(totalXP)
        if baseXP <= 0 { return 1 }
        return Int(pow(baseXP / 100.0, 1.0 / 1.5)) + 1
    }
}
