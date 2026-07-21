import Foundation
import SwiftData
import Core

@Model
public final class JournalEntry: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var content: String
    public var moodScore: Double // 0.0 to 10.0
    public var detectedDistortion: String? // "Catastrophizing", "All-or-Nothing", "Filtering"
    public var reframedRationale: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), title: String, content: String, moodScore: Double = 5.0, detectedDistortion: String? = nil, reframedRationale: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.moodScore = moodScore
        self.detectedDistortion = detectedDistortion
        self.reframedRationale = reframedRationale
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
