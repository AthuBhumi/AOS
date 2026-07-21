import Foundation
import SwiftData
import Core

@Model
public final class ChatMessage: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var advisor: String // "CTO", "CFO", "CMO", "COACH"
    public var role: String // "user", "assistant", "system"
    public var content: String
    public var correlationId: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, advisor: String, role: String, content: String, correlationId: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.advisor = advisor
        self.role = role
        self.content = content
        self.correlationId = correlationId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
