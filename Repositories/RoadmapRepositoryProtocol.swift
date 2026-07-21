import Foundation
import Models

public protocol RoadmapRepositoryProtocol {
    func fetchNodes() throws -> [RoadmapNode]
    func saveNode(_ node: RoadmapNode) throws
    func unlockChildNodes(forParentId parentId: UUID) throws
    func bulkCreateNodes(_ nodes: [RoadmapNode]) throws
}
