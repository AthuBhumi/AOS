import Foundation
import SwiftData
import Core

@Model
public final class RoadmapNode: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var topicDescription: String
    public var studyNotes: String
    public var parentId: UUID?
    public var isLocked: Bool
    public var isCompleted: Bool
    public var quizQuestion: String
    public var quizOptions: [String]
    public var correctOptionIndex: Int
    public var xpReward: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), title: String, topicDescription: String = "", studyNotes: String = "", parentId: UUID? = nil, isLocked: Bool = true, isCompleted: Bool = false, quizQuestion: String = "", quizOptions: [String] = [], correctOptionIndex: Int = 0, xpReward: Int = 50, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.title = title
        self.topicDescription = topicDescription
        self.studyNotes = studyNotes
        self.parentId = parentId
        self.isLocked = isLocked
        self.isCompleted = isCompleted
        self.quizQuestion = quizQuestion
        self.quizOptions = quizOptions
        self.correctOptionIndex = correctOptionIndex
        self.xpReward = xpReward
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
