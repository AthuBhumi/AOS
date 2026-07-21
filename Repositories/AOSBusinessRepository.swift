import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSBusinessRepository: BusinessRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSBusinessRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchCanvas(forUser userId: UUID) throws -> LeanCanvas? {
        let descriptor = FetchDescriptor<LeanCanvas>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted }
        )
        
        do {
            return try context.fetch(descriptor).first
        } catch {
            AOSLogger.shared.error("Failed to fetch LeanCanvas: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveCanvas(_ canvas: LeanCanvas) throws {
        context.insert(canvas)
        canvas.incrementClock()
        canvas.syncState = 2 // Pending Update
        try storageManager.save()
    }
}
