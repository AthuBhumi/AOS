import Foundation
import SwiftData
import Core

@Model
public final class TypingSession: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var targetPhrase: String
    public var typedPhrase: String
    public var wpm: Double
    public var accuracy: Double
    public var timeSpentSeconds: Double
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, targetPhrase: String, typedPhrase: String, wpm: Double, accuracy: Double, timeSpentSeconds: Double, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.targetPhrase = targetPhrase
        self.typedPhrase = typedPhrase
        self.wpm = wpm
        self.accuracy = accuracy
        self.timeSpentSeconds = timeSpentSeconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
