import Foundation
import SwiftData
import Core

@Model
public final class Goal: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var title: String
    public var category: String // "Skill", "Career", "Personal"
    public var targetDate: Date
    public var progress: Double
    @Relationship(deleteRule: .cascade) public var keyResults: [KeyResult]
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, title: String, category: String, targetDate: Date = Date().addingTimeInterval(86400 * 30), progress: Double = 0.0, keyResults: [KeyResult] = [], createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.title = title
        self.category = category
        self.targetDate = targetDate
        self.progress = progress
        self.keyResults = keyResults
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class KeyResult {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var isCompleted: Bool
    public var goal: Goal?
    
    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false, goal: Goal? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.goal = goal
    }
}
