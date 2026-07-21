import Foundation
import SwiftData
import Core

@Model
public final class DailyMission: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var attribute: String // e.g. "STR", "INT", "CHA", "FOR"
    public var xpReward: Int
    public var isCompleted: Bool
    public var dateScheduled: Date
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), title: String, attribute: String, xpReward: Int, isCompleted: Bool = false, dateScheduled: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.title = title
        self.attribute = attribute
        self.xpReward = xpReward
        self.isCompleted = isCompleted
        self.dateScheduled = dateScheduled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
