import Foundation
import SwiftData
import Core

@Model
public final class Habit: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var title: String
    public var cueText: String
    public var responseText: String
    public var rewardText: String
    public var activeStreak: Int
    public var completionHistory: [Date]
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, title: String, cueText: String = "", responseText: String = "", rewardText: String = "", activeStreak: Int = 0, completionHistory: [Date] = [], createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.title = title
        self.cueText = cueText
        self.responseText = responseText
        self.rewardText = rewardText
        self.activeStreak = activeStreak
        self.completionHistory = completionHistory
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
