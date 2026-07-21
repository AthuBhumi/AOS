import Foundation
import SwiftData
import Core

@Model
public final class CEODecision: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var title: String
    public var optionsList: String // Comma separated choices
    public var isResolved: Bool
    public var chosenOption: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, title: String, optionsList: String, isResolved: Bool = false, chosenOption: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.title = title
        self.optionsList = optionsList
        self.isResolved = isResolved
        self.chosenOption = chosenOption
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
