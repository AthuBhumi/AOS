import Foundation
import SwiftData
import Core

@Model
public final class Flashcard: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var bookId: UUID
    public var question: String
    public var answer: String
    public var interval: Int // days
    public var easeFactor: Double
    public var repetitions: Int
    public var nextReviewDate: Date
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), bookId: UUID, question: String, answer: String, interval: Int = 1, easeFactor: Double = 2.5, repetitions: Int = 0, nextReviewDate: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.bookId = bookId
        self.question = question
        self.answer = answer
        self.interval = interval
        self.easeFactor = easeFactor
        self.repetitions = repetitions
        self.nextReviewDate = nextReviewDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
