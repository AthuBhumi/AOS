import Foundation
import SwiftData
import Core

@Model
public final class Book: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var author: String
    public var totalPages: Int
    public var completedPages: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), title: String, author: String, totalPages: Int, completedPages: Int = 0, createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.title = title
        self.author = author
        self.totalPages = totalPages
        self.completedPages = completedPages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
