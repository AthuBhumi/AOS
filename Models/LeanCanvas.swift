import Foundation
import SwiftData
import Core

@Model
public final class LeanCanvas: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var startupName: String
    
    // The 9 Lean Canvas Boxes
    public var problem: String
    public var solution: String
    public var uniqueValueProp: String
    public var unfairAdvantage: String
    public var customerSegments: String
    public var channels: String
    public var keyMetrics: String
    public var costStructure: String
    public var revenueStreams: String
    
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(id: UUID = UUID(), userId: UUID, startupName: String, problem: String = "", solution: String = "", uniqueValueProp: String = "", unfairAdvantage: String = "", customerSegments: String = "", channels: String = "", keyMetrics: String = "", costStructure: String = "", revenueStreams: String = "", createdAt: Date = Date(), updatedAt: Date = Date(), syncState: Int = 1, vectorClock: Int = 1, isDeleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.startupName = startupName
        self.problem = problem
        self.solution = solution
        self.uniqueValueProp = uniqueValueProp
        self.unfairAdvantage = unfairAdvantage
        self.customerSegments = customerSegments
        self.channels = channels
        self.keyMetrics = keyMetrics
        self.costStructure = costStructure
        self.revenueStreams = revenueStreams
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}
