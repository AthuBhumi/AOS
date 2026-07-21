import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSRoadmapRepository: RoadmapRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSRoadmapRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchNodes() throws -> [RoadmapNode] {
        let descriptor = FetchDescriptor<RoadmapNode>(
            predicate: #Predicate { !$0.isDeleted }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch RoadmapNodes: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveNode(_ node: RoadmapNode) throws {
        context.insert(node)
        node.incrementClock()
        node.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func unlockChildNodes(forParentId parentId: UUID) throws {
        let descriptor = FetchDescriptor<RoadmapNode>(
            predicate: #Predicate { $0.parentId == parentId && !$0.isDeleted }
        )
        
        do {
            let childNodes = try context.fetch(descriptor)
            for child in childNodes {
                child.isLocked = false
                child.incrementClock()
                child.syncState = 2 // Pending Update
            }
            try storageManager.save()
        } catch {
            AOSLogger.shared.error("Failed to unlock child nodes: \(error.localizedDescription)")
            throw StorageError.saveFailed(error)
        }
    }
    
    public func bulkCreateNodes(_ nodes: [RoadmapNode]) throws {
        for node in nodes {
            context.insert(node)
            node.syncState = 1 // Pending Create
        }
        try storageManager.save()
    }
}
