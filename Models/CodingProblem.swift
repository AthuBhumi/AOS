import Foundation
import SwiftData
import Core

@Model
public final class CodingProblem: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var difficulty: String // "Easy", "Medium", "Hard"
    public var problemDescription: String
    public var codeBoilerplate: String
    public var isCompleted: Bool
    public var xpReward: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), title: String, difficulty: String, problemDescription: String, codeBoilerplate: String, isCompleted: Bool = false, xpReward: Int = 100, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.problemDescription = problemDescription
        self.codeBoilerplate = codeBoilerplate
        self.isCompleted = isCompleted
        self.xpReward = xpReward
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
